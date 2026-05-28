import torch
import time

duration_in_minutes = 2
target_elements = 536870912
side_length = int(target_elements**0.5)

print(f"Allocation ~2GB VRAM using a {side_length} x{side_length} tensor..")
dummy_tensor = torch.empty((side_length, side_length), device='cuda')

start_time = time.time()
duration = duration_in_minutes*60

print(f"Starting operations...")
while time.time()-start_time < duration:
    _ = torch.matmul(dummy_tensor[:100, :100], dummy_tensor[:100,:100])
    time.sleep(1)

print(f"{duration_in_minutes} minutes elapsed. Task completed")
