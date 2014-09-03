"Exports: Simple_Cluster_Container"
abstract Cluster
abstract Cluster_Container
type Simple_Cluster_Container <: Cluster_Container
	#This is a simple cluster container. It is an additive type containing an object, and an array of references to which cluster the object belongs to.
	object
	compared_quantity #This is the quantity of the object that one desires to measure against
	membership
end
export Simple_Cluster_Container
#=type Simple_Cluster <: Cluster=#
	#="""The simple cluster contains a dictionary of cluster profiles (centroids, etc.) indexed to an array of cluster containers. It also contains=#
#=end=#
abstract Membership_Criteria                                                                                                                                                                                 
export Membership_Criteria
abstract Threshold_Criteria <: Membership_Criteria                                                                                                                                                           
export Threshold_Criteria
type Simple_Threshold_Criteria <: Threshold_Criteria                                                                                                                                                         
        compared_quantity# The quantity of the object you wish to compare against
	#This is now purely for illustrative purposes and is not used in the clustering code
	compared_quantity_accessor::Function
	"""The change from compared_quantity::Symbol to compared_quantity_accessor makes the API more confusing, but also more robust: it is an almost necessary change in order to do the divisive clustering this library was built for. Now, instead of passing a symbol that points to a type field, instead, this now asks for an accessor function you would call on an object of the type you want to perform the clustering against. That is where the library will get the value it is going to cluster with"""
	distance_function                                                                                                                                                                                    
        threshold                                                                                                                                                                                            
end                                                                                                                                                                                                          
export Simple_Threshold_Criteria  
