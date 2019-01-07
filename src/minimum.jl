"""
```
t = find_threshold(MinThreshold(),  histogram, edges)
```

Under the assumption that the histogram is bimodal the histogram is smoothed using 3-mean smoothing untill modes remain. The threshold is then set such that it is the minumum value between these two modes.

# Arguments

The function arguments are described in more detail below.

##  `histogram`

An `AbstractArray` storing the frequency distribution.

##  `edges`

An `AbstractRange` specifying how the intervals for the frequency distribution
are divided.

## Reference

TBA
"""

function find_threshold(algorithm::MinThreshold, histogram::AbstractArray, edges::AbstractRange)
    #initilize number of maximums to be all values and create local copy of histogram
    numMax=length(histogram)
    histogramLocal=copy(histogram)
    n = 0

    #smooth histogram untill only two peaks remain
    while numMax > 2
        n += 1
        numMax=0
        smoothHist = []
        for i in eachindex(histogramLocal)
            if (i > 1) && (i < length(histogramLocal))
                m=histogramLocal[i-1]+histogramLocal[i]+histogramLocal[i+1]
                m=m/3
                push!(smoothHist,m)
            end
        end

        for i in eachindex(smoothHist)
            if (i > 1) && (i < length(smoothHist))
                if (smoothHist[i] > smoothHist[i-1]) && (smoothHist[i] > smoothHist[i+1])
                numMax+=1
                end
            end
        end
        histogramLocal = copy(smoothHist)
    end

    #setup initial max, min and threshold value (t)
    min = typemax(Int)
    max = [0.0,0.0]
    maxt = [-1,-1]
    t = -1

    #find local maxima
    for i in eachindex(histogramLocal)
        if (i > 1) && (i < length(histogramLocal))
            if (histogramLocal[i] > histogramLocal[i-1]) && (histogramLocal[i] > histogramLocal[i+1])
                if maxt[1] == -1
                    maxt[1] = i
                    max[1] = histogramLocal[i]
                elseif maxt[2] == -1
                    maxt[2] = i
                    max[2] = histogramLocal[i]
                end
            end
        end
    end

    #swap maxima to be in correct order (needs replacing with built in)
    if maxt[1]>maxt[2]
        temp=maxt[2]
        temp2=maxt
        maxt[2]=maxt[1]
        maxt[1]=temp
        max[2]=max[1]
        max[1]=temp
    end

    #find local minima betwen maxima
    for i = maxt[1]:maxt[2]
        if histogramLocal[i]<min
            min = histogramLocal[i]
            t = i
        end
    end

    #correct to for lost values and scale to histogram
    t = t + n
    t = t * edges[2]
    return t
end