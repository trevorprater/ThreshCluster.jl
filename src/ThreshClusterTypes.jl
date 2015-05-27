"Exports: Simple_Threshold_Criteria, Cluster"

type Cluster
	array::Array{Any,1} #The actual array of objects that forms the cluster
	modifier::Float64 #The largest distance between two objects in the cluster, which acts to widen the threshold for inclusion to a cluster
	seeder::Any # The object that this cluster was seeded from
end

abstract Membership_Criteria
"Theoretically, we could want other kinds of membership criteria for clustering"

export Membership_Criteria
abstract Threshold_Criteria <: Membership_Criteria
"For Threshold Clustering, but perhaps we could support other criteria in future?"
export Threshold_Criteria
type Simple_Threshold_Criteria <: Threshold_Criteria
        compared_quantity # The quantity of the object you wish to compare against, purely for book keeping, the accessor method is the only actually important part
	compared_quantity_accessor::Function
	"The method applied to an object that returns the quantity you wish to cluster against"
	"""e.g: if we are clustering cats by their tail length, then compared_quantity_accessor could be: 
		function get_tail_length(cat::Cat)
			return cat.tail_length
		end
	Or more simply with a lambda:
	compared_quantity_accessor = cat-> cat.tail_length"""
	distance_function
	"A metric that measures two values you obtain via the compared_quantity accessor"
	"""e.g: if we are clustering cats by their tail length, then distance_function could be:
		function 2norm(tail_length1, tail_length2)
			return abs(tail_length1 - tail_length2)
		end
	"""
        threshold
end
export Simple_Threshold_Criteria  
