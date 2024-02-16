(f={
	|n|

	n.collect(_+1).powerset.select({|i|i.size==2}).sort({|a,b|  if(a[0]!=b[0],{ a[0]<b[0] },{a[1]<b[1]})   })
})



f.value(0)






       0 1 2
		 3 4
		   5

3 sensors
[ / , 12 , 13]  // n-1 + (i+1)
[ / , /  , 23]  // n
[ / , /  ,  /]


 12 13 14
    23 24
       34








a=[0,1,2,3,4,5,6]
a.clump(a.size/1)





