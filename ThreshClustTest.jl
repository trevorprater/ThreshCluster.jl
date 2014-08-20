using ThreshCluster
mydistance(a,b) = abs(a-b)
threshcrit = Simple_Threshold_Criteria(:size,mydistance,4)
type Fish
	size
end
array_of_fish = [Fish(2),Fish(5),Fish(64),Fish(12)]
println("array_of_fish\n",array_of_fish)

(cluster_lookup,myarray) = make_simple_threshold_clusters(array_of_fish,threshcrit)
println(cluster_lookup)
println(myarray)
