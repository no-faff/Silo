#!/usr/bin/env python3
"""Native messaging host for Silo. Receives a URL from a browser extension and opens it with Silo."""

import json
import os
import shutil
import struct
import subprocess
import sys


def read_message():
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    length = struct.unpack("@I", raw_length)[0]
    message = sys.stdin.buffer.read(length).decode("utf-8")
    return json.loads(message)


def main():
    msg = read_message()
    if msg and "url" in msg:
        silo_bin = shutil.which("silo")
        if not silo_bin:
            fallback = os.path.expanduser("~/.local/bin/silo")
            if os.path.isfile(fallback) and os.access(fallback, os.X_OK):
                silo_bin = fallback

        if silo_bin:
            subprocess.Popen([silo_bin, msg["url"]])


if __name__ == "__main__":
    main()
