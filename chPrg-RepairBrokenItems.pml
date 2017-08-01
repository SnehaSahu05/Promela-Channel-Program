/* QUESTION
 * Client sends item to mover for repairing & counts the no. of items recieved.
 *			Clients breaks after sending 100 items & also asserts if repaired is greater than broken.
 * Mover forwards items recieved from client to repairService &
 *			those from repairService to the client.
 * RepairService repairs an item recieved with (3/4) propability and sends back.
 */


/* 
 * CLIENT --> MOVER --> REPAIRSERVICE 
 * 2 RENDEZVOUS CHANNELS : 1 client-mover channel ~ cm
 *                       & 1 mover-repairservice  ~ mr
 * i.e. atomic channels (send followed by recieve)
 */
 
mtype = {BROKEN, REPAIRED}
 
chan cm = [0] of {mtype};
chan mr = [0] of {mtype};

active proctype client() {
	mtype item, itemR;
	int b=0, r=0, sum=0;
	sum=b+r;
	
	do
	 :: sum<100 
		 -> if	//randomnly decide item quality
			 :: item = BROKEN
			 :: item = REPAIRED
			fi
			atomic{ printf("\n %d client sent %e", sum+1, item); cm!item		// send item to mover
			if					// if mover reads channel, then client waits for reply
			 :: empty(cm) -> cm?itemR; printf("\tclient recieved item %d as %e", sum+1, itemR);
			fi
			if	// check & count recieved item
			 :: itemR == BROKEN -> b++;
			 :: itemR == REPAIRED -> r++;
			fi
			sum=b+r;			// record no. of items sent
			}
	 :: else					// when 100 items sent across cm channel to mover
		 -> atomic{
			assert(r>b);		// check if repaired is more than broken
			if
			 :: r>b -> printf("\n\n !! REPAIRED count is high !!\n\n")
			 :: r<b -> printf("\n\n !! BROKEN count is high !!\n\n")
			fi
			break;}				// & break
	od
}

active proctype repairservice() {
	mtype item;
	do 
	 :: mr?item;	// wait until an item is recieved
		atomic {
		if	// non-deterministically repair a broken item
		 :: item == BROKEN -> item = REPAIRED	// (3/4) chance that a broken item is repaired
		 :: item == BROKEN -> item = REPAIRED
		 :: item == BROKEN -> item = REPAIRED
		 :: item == BROKEN -> item = BROKEN
		 :: item == REPAIRED -> item = REPAIRED
		fi
		printf("\t item %e", item);
		mr!item;	// send repaired item to mover
		}
	od
}

active proctype mover(){
	mtype item;
	do
	 :: cm?item -> mr!item;
	 :: mr?item -> cm!item;
//	 :: empty(cm) -> atomic{ mr?item; cm!item;}
	od
}