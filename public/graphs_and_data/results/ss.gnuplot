set title "Average idle time"

f(x) = a*x+b
g(x) = c*x+d
h(x) = e*x+f
i(x) = g*x+h

fit f(x) 'RandomRouting.plot' u 1:2 via a,b
fit g(x) 'RoundRobinRouting.plot' u 1:2 via c,d
fit h(x) 'ShortestQueueRouting.plot' u 1:2 every ::20 via e,f 
fit i(x) 'SmartRouting.plot' u 1:2 every ::20 via g,h

plot f(x) w lines, 'RandomRouting.plot' using 1:2:3 w yerrorlines, g(x) w lines, 'RoundRobinRouting.plot' using 1:2:3 w yerrorlines, h(x) w lines, 'ShortestQueueRouting.plot' u 1:2:3 w yerrorlines, i(x) w lines, 'SmartRouting.plot' u 1:2:3 w yerrorlines
