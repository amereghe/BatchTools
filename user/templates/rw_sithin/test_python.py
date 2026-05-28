import os
import pandas as pd
import SimpleITK as sitk
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

NUM_WORKERS = 4

DATA_DIR = r"/home/luna/research/dataset/curated/Meningioma/"
OUT_DIR = r"results"
LABEL_DF = pd.read_csv(os.path.join(DATA_DIR, "label_df.csv")).sort_values(by="pid").reset_index(drop=True)

def parse(pid):

    img = sitk.ReadImage(os.path.join(DATA_DIR, pid, "img", "ct.nii.gz"))
    sitk.WriteImage(img, os.path.join(OUT_DIR, f"{pid}.nii.gz"))

if __name__=="__main__":
    if not os.path.exists(OUT_DIR):
        os.makedirs(OUT_DIR)
    
    LABEL_DF = pd.read_csv(os.path.join(DATA_DIR, "label_df.csv")).sort_values(by="pid").reset_index(drop=True)
    PIDS = LABEL_DF.pid.to_list()[:10]
    
    with ThreadPoolExecutor(max_workers=4) as e:
        futures = [e.submit(parse, pid) for pid in PIDS]
        for future in tqdm(as_completed(futures), position=0, total=len(futures), desc="parsing records"):
            _ = future.result()

