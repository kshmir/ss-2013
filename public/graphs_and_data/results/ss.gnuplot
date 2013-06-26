set title "Average server idle time"

f(x) = a*x+b
g(x) = c*x+d
h(x) = e*x+f
i(x) = g*x+h

fit f(x) 'RandomRouting.plot' u 1:4 via a,b
fit g(x) 'RoundRobinRouting.plot' u 1:4 via c,d
fit h(x) 'ShortestQueueRouting.plot' u 1:4 via e,f
fit i(x) 'SmartRouting.plot' u 1:4 via g,h

plot f(x) w lines, 'RandomRouting.plot' using 1:4:5 w yerrorlines, g(x) w lines, 'RoundRobinRouting.plot' using 1:4:5 w yerrorlines, h(x) w lines, 'ShortestQueueRouting.plot' u 1:4:5 w yerrorlines, i(x) w lines, 'SmartRouting.plot' u 1:4:5 w yerrorlines
