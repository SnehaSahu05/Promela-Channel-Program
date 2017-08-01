# Promela-Channel-Programming
### REPAIR BROKEN ITEMS over RENDEZVOUS CHANNELS 


Client
  > sends item to mover for repairing & counts the no. of items recieved.
  
  > stops after sending 100 items & also asserts if count of repaired is greater than broken.


Mover 
  > forwards items recieved from client to repairService
  
  > forwards items from repairService to the client.

RepairService
  > repairs an item recieved with (3/4) success propability in case it was broken and sends it back.
