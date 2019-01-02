function checkKSuitability(K, radius)

errormsg = 'K value is larger than Minor Patch (Pmin) size.';
if K > power((2*radius+1), 2); error(errormsg); end

end

