
import time
from concurrent.futures import ThreadPoolExecutor

def getfilenames():
    return [f'{i}.txt' for i in range(10)]

def readlines(filename):
    print(f'processing {filename}')
    # time.sleep(1)
    return [f'line {i}' for i in range(10**6)]


if __name__ == "__main__":
    t1 = time.perf_counter(), time.process_time()
    threads = []
    with ThreadPoolExecutor(max_workers=8) as executor:
        for filename in getfilenames():
            print(f"{filename}")
            threads.append(executor.submit(readlines, filename))

    total = 0
    for i in threads:
        total += len(i.result())

    t2 = time.perf_counter(), time.process_time()

    print()
    print(f"Real time: {t2[0] - t1[0]:.2f} seconds")
    print(f"CPU time: {t2[1] - t1[1]:.2f} seconds")
    print(f"Total lines: {total:,}")
    print()
