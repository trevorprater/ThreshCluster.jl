module ThreshClust
using Codecs
using Debug
#This is an API for doing simple clustering with an array of data points and a metric that can be applied to any member of those data points. Ideally, the API for this clustering
#mechanism should need nothing more than to be passed an array and a distance function and do all the work on its own. We'll see how well that goal works out."""
using ThreshClustTypes
abstract Membership_Criteria
abstract Threshold_Criteria <: Membership_Criteria
type Simple_Threshold_Criteria <: Threshold_Criteria
	compared_quantity::Symbol # The quantity of the object you wish to compare against
	distance_function
	threshold
end
export Simple_Threshold_Criteria

#The next thing to implement is ordered threshold clustering, wherein we include an ordering function.
#Then, the "clustered_start" function can start by ordering the elements of the culled set.
#If we can do that, then we're in good shape, as at that point, all we need to do is 
#test out in either direction from a given point whether or not it is in a neighbor cluster

function make_simple_threshold_clusters(array,threshcrit::Threshold_Criteria)
	capsulearray = initialize_cluster_containers(array,threshcrit.compared_quantity)
	clusters = develop_clusters(capsulearray,threshcrit)
	(cluster_lookup,cleaned_clusters) = clean_clusters(clusters)
	return  (cluster_lookup,cleaned_clusters)
end
export make_simple_threshold_clusters

function initialize_cluster_containers(array,compared_quantity)
	#Encapsulates all elements of the array into a cluster_container object, so that each object can have its membership information associated with it.
	map(x->Simple_Cluster_Container(x,compared_quantity,Set(x.(compared_quantity))),array)
end


function develop_clusters(caparray,threshcrit)
	culled_set = cull_compared_quantities(caparray,threshcrit.compared_quantity)
	memberships = assign_relative_clusters(culled_set,threshcrit)
	#=culled_membership = cull_clusters(clustered_start)=#
	clustered_end = bake_clusters(memberships,caparray,threshcrit)
end

function cull_compared_quantities(caparray,compared_quantity)
	#We want to do as much processing as possible on the quantities to compare themselves
	#and very little on the objects, so we use this to pull each element of our array
	map(x->Set(x.object.(compared_quantity)),caparray)
end

function assign_relative_clusters(culled_set,threshcrit)
	"""Compares each element in the set with each other element in the set. Then, when we have
	two elements that are the same, we add that to the comparing element's dictionary."""
	memberships = Dict()
	"""The process for this is as follows:
		1. We check to see who is in the cluster that is represented by a given element
		2. We then put that cluster in the cluster lookup, and index it in.
		3. The cluster is indexed by this cluster lookup
	This function can return the cluster index as well, but why?"""
	for compquantset in culled_set
		compquant = collect(compquantset)[1]
		#^ Needed because each element is a set: we need to get each element out of the set
		compsym = symbol(string(compquant))
		memberships = merge(memberships,{compsym => Set()})
		#=@bp=#
		for otherquantset in setdiff(culled_set,Set(compquant))
			otherquant = collect(otherquantset)[1]
			if threshcrit.distance_function(compquant,otherquant) < threshcrit.threshold
				memberships[compsym] = union(memberships[compsym],otherquant)
			end
		end
	end

	return memberships
end
function to_set(array)
	reduce(union,map(Set,array))
end
"""The above function was briefly considered, but, since the membership of a given object to its cluster is determined as a set, there's nothing to really gain by differentiating different sets, except perhaps memory effeciency, which can be optimized against later"""





		

function bake_clusters(memberships,caparray,threshcrit)
	for clustcont in caparray
		#The membership of a cluster container is equal to the set of values of
		#=@bp=#
		quantsym = symbol(string(clustcont.object.(threshcrit.compared_quantity)))
		clustcont.membership = memberships[quantsym]
	end
	return caparray
end

@debug function clean_clusters(oldcaparray)
	#Indexes the clusters by cluster number, rather than the members of the cluster
	caparray = oldcaparray
	cluster_lookup = Dict()
	cluster_num = 1
	for i in 1:length(caparray)
		if isa(caparray[i].membership, Real)
			continue
		else
		testingmembership = caparray[i].membership
		caparray[i].membership = cluster_num
		for j in i:length(caparray)
			if caparray[j].membership == testingmembership
				caparray[j].membership = cluster_num
			end
		end
		merge!(cluster_lookup,{cluster_num => testingmembership})
		cluster_num = cluster_num + 1
		end
	end
	return (cluster_lookup,caparray) 
end
end #End Module
