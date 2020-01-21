#Read two bytes
,>,
<
#{mem(6) mem(7)} = mem(0) * mem(1)
[
  #reduce mem(0)
  -
  >
  #add mem(1) to mem(2)
  [->+
    #Catch the carry and put it to mem(6)
    [->>+>+<<<]
    >>[-<<+>>]
    >>+
    <
    [[-]>-<]

    <<+<<
  ]
  >>
  [-<<+>>]
  <<<
]
#output the result
>>>>>>[.[-]]
<<<<.
