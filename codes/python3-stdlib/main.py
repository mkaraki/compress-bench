import zlib
import gzip
import bz2
import lzma
import sys
import os
import csv
import platform
import time


if __name__ == '__main__':
    datasets_dir = sys.argv[1]
    result_dir = sys.argv[2]

    python_ver = platform.python_version()
    
    for dataset in os.listdir(datasets_dir):
        dataset_file = os.path.join(datasets_dir, dataset)

        if not os.path.isfile(dataset_file):
            continue

        dataset_filename = os.path.basename(dataset_file)

        if (dataset_filename.startswith('.')):
            continue

        with open(dataset_file, 'rb') as f:
            data = f.read()
            
            result_path = os.path.join(result_dir, dataset_filename + '.csv')
            with open(result_path, 'a', encoding='utf-8') as fr:
                result = csv.writer(fr, lineterminator='\n')
                
                # zlib
                for level in range(1, 10):
                    c_start = time.time()
                    compressed = zlib.compress(data, level, wbits=zlib.MAX_WBITS)
                    c_end = time.time()

                    d_start = time.time()
                    _ = zlib.decompress(compressed, wbits=zlib.MAX_WBITS)
                    d_end = time.time()

                    c_time = c_end - c_start
                    d_time = d_end - d_start

                    ratio = len(compressed) / len(data) * 100

                    result.writerow(['Python zlib', python_ver, f'level={level}, wbits=MAX_WBITS', ratio, len(data), len(compressed), c_time, d_time])

                # gzip
                for level in range(1, 10):
                    c_start = time.time()
                    compressed = gzip.compress(data, compresslevel=level, mtime=None)
                    c_end = time.time()

                    d_start = time.time()
                    _ = gzip.decompress(compressed)
                    d_end = time.time()

                    c_time = c_end - c_start
                    d_time = d_end - d_start

                    ratio = len(compressed) / len(data) * 100

                    result.writerow(['Python gzip', python_ver, f'compresslevel={level}, mtime=None', ratio, len(data), len(compressed), c_time, d_time])

                # bz2
                for level in range(1, 10):
                    c_start = time.time()
                    compressed = bz2.compress(data, compresslevel=level)
                    c_end = time.time()

                    d_start = time.time()
                    _ = bz2.decompress(compressed)
                    d_end = time.time()

                    c_time = c_end - c_start
                    d_time = d_end - d_start

                    ratio = len(compressed) / len(data) * 100

                    result.writerow(['Python bz2', python_ver, f'compresslevel={level}', ratio, len(data), len(compressed), c_time, d_time])

                # lzma
                for level in range(0, 10):
                    c_start = time.time()
                    compressed = lzma.compress(
                            data, 
                            format=lzma.FORMAT_XZ, 
                            check=lzma.CHECK_CRC64, 
                            preset=level,
                            filters=None
                        )
                    c_end = time.time()

                    d_start = time.time()
                    _ = lzma.decompress(compressed)
                    d_end = time.time()

                    c_time = c_end - c_start
                    d_time = d_end - d_start

                    ratio = len(compressed) / len(data) * 100

                    result.writerow(['Python lzma (xz)', python_ver, f'format=FORMAT_XZ, check=CHECK_CRC64, preset={level}, filters=None', ratio, len(data), len(compressed), c_time, d_time])

                # We won't test zip in Python.
                # Python may not provide one shot zip compression into args.
