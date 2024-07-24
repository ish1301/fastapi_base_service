import time
from multiprocessing import Pool


def getfilenames():
    return [f'{i}.txt' for i in range(10)]

def readlines(filename):
    print(f'processing {filename}')
    return [f'line {i}'for i in range(10**7)]

if __name__ == "__main__":
    t1 = time.perf_counter(), time.process_time()

    pool = Pool(processes=4)
    for filename in getfilenames():
        print(f"starting {filename}")
        pool.apply_async(readlines, [filename])
    pool.close()
    pool.join()

    t2 = time.perf_counter(), time.process_time()

    print()
    print(f"Real time: {t2[0] - t1[0]:.2f} seconds")
    print(f"CPU time: {t2[1] - t1[1]:.2f} seconds")
    # print(f"Total lines: {total:,}")
    print()

