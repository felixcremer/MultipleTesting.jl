module MultipleTesting
using YAXArrays
import ImageMorphology: label_components

function permutedtests(data, teststat; dims="Time")
    

end


"""
    maskcluster(teststat, testlabels, clusterthresh)

Mask significant clusters in teststat based on the component labels as cluster indicators. 
The threshold `clusterthresh` gives the minimal size of a cluster that is kept.
""" 
function maskcluster(teststatisticvalue, testlabels, clusterthresh; indims=(InDims("X", "Y"), InDims("X", "Y")), outdims=OutDims("X", "Y"))
    mapCube(maskcluster!, (teststatisticvalue, testlabels), clusterthresh; indims, outdims)
end
"""
    maskcluster!(output, testval, inputlabels, clusterthresh)
Inner function for the masking of the significant cluster.
"""
function maskcluster!(output, testval, inputlabels, clusterthresh)
    inputlabels[ismissing.(inputlabels)] .= 0
    inputlabels = collect(Int,inputlabels)

    complengths = component_lengths(inputlabels)
    compinds = component_indices(inputlabels)
    for i in eachindex(complengths)
        if complengths[i] < clusterthresh
            inputlabels[compinds[i]] .= 0
        end
    end
    output .= .!iszero.(inputlabels) .* testval
end

"""
    getlabels!(labelsout, xin)
Compute the labels for the data in `xin` and save it in `labelsout`.
This uses the `label_components` function from ImageMorphology.
"""
function getlabels!(labelsout, xin)
    xin[ismissing.(xin)] .= 0
    labels  = label_components(xin, trues(3,3))
    #sizeout .= maximum(component_lengths(labels)[1:end])
    labelsout .= labels
end
label_components(testval::YAXArray; indims=InDims("X", "Y"), outdims=OutDims("X","Y", outtype=Int,path=tempname()*".zarr")) = mapCube(getlabels!, testval; indims, outdims)

end