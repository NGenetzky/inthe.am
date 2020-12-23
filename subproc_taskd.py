#!/usr/bin/python

import os
import subprocess

class TaskdError(Exception):
    pass

class TaskdSubproc(object):
    TASKD_BINARY = os.environ.get("TASKD_BINARY", "/usr/bin/taskd")
    def __init__(self):
        self._cmd = []
        self._env = os.environ.copy()

    def run(self, command):
        key_proc = subprocess.Popen(
            command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=self._env,
        )
        key_proc_output = key_proc.communicate()[0].decode("utf-8").split("\n")
        taskd_user_key = key_proc_output[0].split(":")[1].strip()
        result = key_proc.wait()
        if result != 0:
            raise TaskdError()

    def add_user(self, org_name, user_name):
        self.run([self.TASKD_BINARY, "add", "user", org_name, user_name])

    # TODO
    # def communicate():
    #     proc = subprocess.Popen(...)
    #     try:
    #         outs, errs = proc.communicate(timeout=15)
    #     except TimeoutExpired:
    #         proc.kill()
    #         outs, errs = proc.communicate()

if __name__ == "__main__":
    taskd = TaskdSubproc()
    taskd.add_user('foo', 'bar')
