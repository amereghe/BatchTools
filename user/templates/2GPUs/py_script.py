import torch
import time

print(f"# gpus = {torch.cuda.device_count()}")

duration_in_minutes = 1
target_elements = 536870912
side_length = int(target_elements**0.5)

print(f"Allocation 2 x ~2GB VRAM using two {side_length} x{side_length} tensor..")
dummy_tensor1 = torch.empty((side_length, side_length), device='cuda:0')
dummy_tensor2 = torch.empty((side_length, side_length), device='cuda:1')

start_time = time.time()
duration = duration_in_minutes*60

print(f"Starting operations...")
while time.time()-start_time < duration:
    _ = torch.matmul(dummy_tensor1[:100, :100], dummy_tensor1[:100, :100])
    _ = torch.matmul(dummy_tensor2[:100, :100], dummy_tensor2[:100, :100])
    time.sleep(1)

print(f"{duration_in_minutes} minutes elapsed. Task completed")
