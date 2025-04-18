#!/usr/bin/env python3
"""
Wrapper for ansible-lint to avoid using OS semaphores that may be disallowed in sandbox.
Monkey-patches multiprocessing.Semaphore to use threading.BoundedSemaphore (thread-based).
"""
import os
os.environ.setdefault('ANSIBLE_CONFIG', os.path.join(os.getcwd(), 'ansible/ansible.cfg'))
import multiprocessing
from threading import BoundedSemaphore

# Override Semaphore to avoid system-level semaphore creation
multiprocessing.Semaphore = BoundedSemaphore

import sys
from ansiblelint.__main__ import main

if __name__ == "__main__":
    sys.exit(main())