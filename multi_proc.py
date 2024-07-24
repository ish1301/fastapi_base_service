import time
from multiprocessing import Pool


def getfilenames():
    return [f'{i}.txt' for i in range(10)]

def readlines(filename):
    print(f"processing {filename}")
    return [f'line {i}'for i in range(10**6)]

if __name__ == "__main__":
    t1 = time.perf_counter(), time.process_time()

    pool = Pool(processes=8)
    results = []
    for filename in getfilenames():
        print(f"starting {filename}")
        results.append(pool.apply_async(readlines, [filename,]))

    pool.close()
    pool.join()

    total = 0
    for i in results:
        total += len(i.get(timeout=1))

    t2 = time.perf_counter(), time.process_time()

    print()
    print(f"Real time: {t2[0] - t1[0]:.2f} seconds")
    print(f"CPU time: {t2[1] - t1[1]:.2f} seconds")
    print(f"Total lines: {total:,}")
    print()

