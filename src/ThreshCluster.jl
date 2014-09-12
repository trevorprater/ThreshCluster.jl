module ThreshCluster
#This is an API for doing simple clustering with an array of data points and a metric that can be applied to any member of those data points. Ideally, the API for this clustering
#mechanism should need nothing more than to be passed an array and a distance function and do all the work on its own. We'll see how well that goal works out."""
include("ThreshClusterTypes.jl")
#The next thing to implement is ordered threshold clustering, wherein we include an ordering function.
#Then, the "clustered_start" function can start by ordering the elements of the culled set.
#If we can do that, then we're in good shape, as at that point, all we need to do is 
#test out in either direction from a given point whether or not it is in a neighbor cluster

function make_simple_threshold_clusters(array,threshcrit::Threshold_Criteria)
	if length(array) < 1
		return ([],[])
	end
	capsulearray = initialize_cluster_containers(array,threshcrit)
	(memberships,clusters) = develop_clusters(capsulearray,threshcrit)
	tuple = (memberships,clusters)
	return tuple
end
export make_simple_threshold_clusters

function initialize_cluster_containers(array,threshcrit)
	#Encapsulates all elements of the array into a cluster_container object, so that each object can have its membership information associated with it.
	map(x->Simple_Cluster_Container(x,threshcrit.compared_quantity,threshcrit.compared_quantity_accessor(x)),array)
end


function develop_clusters(caparray,threshcrit)
	#Pull out the values we're doing comparisons on, and run unique on them
	cleaned_array = cull_compared_quantities(caparray,threshcrit)
	#assign_relative_clusters does too much work
	#Return from the cleaned array a hash of each element of the cleaned_array's membership
	memberships = assign_relative_clusters(cleaned_array,threshcrit)
	#I don't remember what this is supposed to do
	#=culled_membership = cull_clusters(clustered_start)=#
	clustered_end = bake_clusters(memberships,caparray,cleaned_array,threshcrit)
	return (memberships,clustered_end)
end

function cull_compared_quantities(caparray,threshcrit)
	#We want to do as much processing as possible on the quantities to compare themselves
	#and very little on the objects, so we use this to pull each element of our array
	array_of_quantities = map(x->threshcrit.compared_quantity_accessor(x.object),caparray)
	cleaned_array = unique(array_of_quantities)
	return cleaned_array
end

function assign_relative_clusters(culled_array,threshcrit)
	"""Compares each element in the set with each other element in the set. Then, when we have
	two elements that are the same, we add that to the comparing element's dictionary."""
	"""Remember! culled_array is a set of values, not cluster containers.
	We need to assign the memberships back to the array of cluster containers after 
	we've determined memberships based on the values themselves."""
	memberships = Dict()
	#Turn the set into an array
	#=culled_set_array = collect(culled_set)=#
	#Get the length of the array
	culled_array_length = length(culled_array)
	"""The process for this is as follows:
		1. We check to see who is in the cluster that is represented by a given element
		2. We then put that cluster in the cluster lookup, and index it in.
		3. The cluster is indexed by this cluster lookup
	This function can return the cluster index as well, but why?"""
	#For each index in the array
	for quantityindex in 1:culled_array_length
		#Each element of the array is a set, so we need to collect it as well
		compquant = culled_array[quantityindex]
		#=compsym = symbol(string(compquant))=#
		#We index based on your position in the original array
		#First: check to see if we haven't already made dictionary for this index
		if !(haskey(memberships,quantityindex))
			merge!(memberships,{quantityindex => [quantityindex]})
		end

		#=@bp=#
		for otherquantind in quantityindex+1:culled_array_length
			otherquant = culled_array[otherquantind]
			#=otherquantsym = symbol(string(otherquant))=#
			if threshcrit.distance_function(compquant,otherquant) < threshcrit.threshold
				memberships[quantityindex] = [memberships[quantityindex]; otherquantind] 
				if haskey(memberships,otherquantind)
					memberships[otherquantind] = [memberships[otherquantind]; quantityindex]
				else
					memberships[otherquantind] = []
					memberships[otherquantind] = [memberships[otherquantind]; quantityindex]
				end
			end
		end
	end

	return memberships
end
function to_set(array)
	reduce(union,map(Set,array))
end




		

function bake_clusters(memberships,caparray,cleaned_array,threshcrit)
	#Puts membership information into each 
	compared_quantity = threshcrit.compared_quantity

	for clustcont in caparray
		#The membership of a cluster container is equal to the set of values of
		membershipind = find(x->x==threshcrit.compared_quantity_accessor(clustcont.object),cleaned_array)[1]
		clustcont.membership = memberships[membershipind]
	end
	return caparray
end

#=function clean_clusters(oldcaparray)=#
	#=#Indexes the clusters by cluster number, rather than the members of the cluster=#
	#=caparray = oldcaparray=#
	#=cluster_lookup = Dict()=#
	#=cluster_num = 1=#
	#=for i in 1:length(caparray)=#
		#=testingmembership = caparray[i].membership=#
		#=caparray[i].membership = cluster_num=#

		#=for j in i:length(caparray)=#
			#=if caparray[j].membership == testingmembership=#
				#=caparray[j].membership = cluster_num=#
			#=end=#
		#=end=#
		#=merge!(cluster_lookup,{cluster_num => [testingmembership]})=#
		#=cluster_num = cluster_num + 1=#
	#=end=#
	#=return (cluster_lookup,caparray) =#

"""
In this long quote is the old implementation of group_containers_by cluster, which was very ineffecient and could take minutes to do the group, which now appears to be done in just under a second
function group_containers_by_cluster(clustercontainers,cluster_lookup)
	#Returns an array of arrays. Each array contains the elements of the cluster to which the cluster id corresponds to. 
	#I.E: the first array contains all the elements in cluster 1. This is a very stupid and computationally intensive way to do this
	top_group = maximum(collect(keys(cluster_lookup)))
	array_container = {}
	for i = 1:top_group
		cluster_holder = {}
		clusterids = cluster_lookup[i]
		for clusterid in clusterids
			for cluster_container in clustercontainers
				if in(clusterid,cluster_container.membership)
					cluster_holder = [cluster_holder; cluster_container]
				end
			end
		end
		array_container = [array_container; Array[[cluster_holder]]]
		#Super obnoxious to figure out that Julia does not like arrays of arrays
	end
	return array_container
end
"""
function group_containers_by_cluster(cluster_tuple)
	"Returns a hash of arrays, each array containing the elements indexed by that cluster number"
	cluster_lookup = cluster_tuple[1]
	clustercontainers = cluster_tuple[2]
	if length(clustercontainers) < 1
		return []
	end
	top_group = maximum(collect(keys(cluster_lookup)))
	array_container = fill(Any[],(top_group,1))
	map(x->insert_into_container(x,array_container),clustercontainers)
	return array_container
end
export group_containers_by_cluster
function insert_into_container(cluster_container,array_container)
	"Inserts a cluster container into array container, which is a dictionary"
	membership_array = cluster_container.membership
	for membershipid in membership_array
		array_container[membershipid] = vcat(array_container[membershipid],cluster_container.object)
	end
end

function make_and_group_simple_threshold_clusters(array,threshold_criteria::Simple_Threshold_Criteria)
	array_of_tuples = make_simple_threshold_clusters(array,threshold_criteria)
	grouped_array = group_containers_by_cluster(array_of_tuples)
	return grouped_array
end
export make_and_group_simple_threshold_cluster
end
