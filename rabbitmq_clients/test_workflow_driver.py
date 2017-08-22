# Python script to submit N runs of the 'test-workflow'.
# After submitting all runs, the script will wait until the message queue is empty.
#
# Usage: python test_workflow_driver.py <number_of_runs>

import logging
import sys
import datetime
import time
from rabbitmq_producer import publish_messages, wait_for_queues
import threading

LOG_FORMAT = '%(levelname)s: %(message)s'
LOGGER = logging.getLogger(__name__)
LOG_FILE = "test_workflow_driver.log" # in current directory
TEST_WORKFLOW = 'test-workflow'
SLEEP_TIME = 0 # time to wait before sending the next message

def worker(number_of_runs):
    '''Function that sends the messages to execute the runs.'''

    # loop over runs=workflows
    for irun in range(1, number_of_runs+1):
        LOGGER.info("Submitting messages for run #: %s" % irun)
   
        msg_queue = TEST_WORKFLOW
        num_msgs = 1
        msg_dict = { 'Dataset':'abc', 'Project':'123', 'Run':irun }
   
        publish_messages(msg_queue, num_msgs, msg_dict)
   
        # wait before submitting the next run
        time.sleep(SLEEP_TIME)

    return


def main(number_of_runs):
    
    logging.basicConfig(level=logging.CRITICAL, format=LOG_FORMAT)
        
    startTime = datetime.datetime.now()
    logging.critical("Start Time: %s" % startTime.strftime("%Y-%m-%d %H:%M:%S") )

    # send all messages in a separate thread
    # do not wait till completion
    t = threading.Thread(target=worker, args=(number_of_runs,))
    t.start()
    
    # wait for RabbitMQ server to process all messages in all queues
    wait_for_queues(delay_secs=10, sleep_secs=10)
    
    stopTime = datetime.datetime.now()
    logging.critical("Stop Time: %s" % stopTime.strftime("%Y-%m-%d %H:%M:%S") )
    logging.critical("Elapsed Time: %s secs" % (stopTime-startTime).seconds )

    # write log file (append to existing file)
    with open(LOG_FILE, 'a') as log_file:
        log_file.write('number_of_runs=%s\t' % number_of_runs)
        log_file.write('elapsed_time_sec=%s\n' % (stopTime-startTime).seconds)
                        

if __name__ == '__main__':
    """ Parse command line arguments. """
    
    if len(sys.argv) < 1:
        raise Exception("Usage: python test_workflow_driver.py <number_of_runs>")
    else:
        number_of_runs = int( sys.argv[1] )

    main(number_of_runs)
