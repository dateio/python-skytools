
"""Atomic append of gzipped data.

The point is - if several gzip streams are concatenated,
they are read back as one whole stream.
"""

from __future__ import absolute_import, division, print_function

import gzip
from io import BytesIO

__all__ = ['gzip_append']

#
# gzip storage
#


def gzip_append(filename, data, level=6):
    """Append a block of data to file with safety checks."""

    # compress data
    buf = BytesIO()
    with gzip.GzipFile(fileobj=buf, compresslevel=level, mode="w") as g:
        g.write(data)
    zdata = buf.getvalue()

    # append, safely
    with open(filename, "ab+", 0) as f:
        f.seek(0, 2)
        pos = f.tell()
        try:
            f.write(zdata)
        except Exception as ex:
            # rollback on error
            f.seek(pos, 0)
            f.truncate()
            raise ex

