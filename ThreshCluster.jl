#This is an API for doing simple clustering with an array of data points and a metric that can be applied to any member of those data points. Ideally, the API for this clustering
#mechanism should need nothing more than to be passed an array and a distance function and do all the work on its own. We'll see how well that goal works out."""


module ThreshClust
using ThreshClustTypes
abstract Membership_Critera
abstract Threshold_Criteria <: Membership_Criteria
type Simple_Threshold_Criteria <: Threshold_Criteria
	compared_quantity::Symbol # The quantity of the object you wish to compare against
	distance_function
	threshold
end

#The next thing to implement is ordered threshold clustering, wherein we include an ordering function.
#Then, the "clustered_start" function can start by ordering the elements of the culled set.
#If we can do that, then we're in good shape, as at that point, all we need to do is 
#test out in either direction from a given point whether or not it is in a neighbor cluster

function make_simple_threshold_clusters(array,threshcrit::Threshold_Criteria)
	capsulearray = initialize_cluster_containers(array,threshcrit.compared_quantity)
	clusters = develop_clusters(capsulearray,thresh_criteria)
	cluster_dict = make_cluster_dict(clusters)
	return (clusters,cluster_dict)
end

function capsulearray(array,compared_quantity)
	#Encapsulates all elements of the array into a cluster_container object, so that each object can have its membership information associated with it.
	map(x->Simple_Cluster_Container(x,compared_quantity,Set(x.(compared_quantity))),array)
end

function develop_clusters(caparray,threshcrit::Threshold_Criteria)
	culled_set = cull_compared_quantities(caparray,threshcrit.compared_quantity)
	clustered_start = assign_relative_clusters(culled_set,threshcrit)
	clustered_end = bake_clusters(clustered_start,caparray)
end

function cull_uniques(caparray,compared_quantity)
	#We want to do as much processing as possible on the quantities to compare themselves
	#and very little on the objects, so we use this to pull each element of our array
	map(x->Set(x.(compared_quantity)),caparray)
end

function clustered_start(culled_set,threshcrit)
	"""Compares each element in the set with each other element in the set. Then, when we have
	two elements that are the same, we add that to the comparing element's dictionary."""
	memberships = Dict()
	for compquant in culled_set
		compsym = symbol(string(compquant))
		memberships = merge(memberships,{compquant => []})
		for otherquant in setdiff(culled_set,Set(compquant))
			if threshcrit.distance_function(compquant,otherquant) < threshcrit.threshold
				memberships[compsym] = append(memberships[compsym],otherquant)
			end
		end
	end
	return memberships
end

function bake_clusters(memberships,caparray)
	


end #End Module
