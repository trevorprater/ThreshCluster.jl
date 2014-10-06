using ThreshCluster
type MyType
    number
    othernumber
    notanumber
end

my_compared_quantity = :othernumber

my_distance_function(a::Real, b::Real) = abs(a-b)

my_compared_quantity_accessor(mytype::MyType) = mytype.othernumber

my_threshold = 2

array_of_my_types = [MyType(1,2,"foo");MyType(2,4,"bar");MyType(6,8,"Baz")]


my_thresholding_criteria = Simple_Threshold_Criteria(my_compared_quantity,
                             my_compared_quantity_accessor,
			     my_distance_function,
                             my_threshold)

array_of_clustered_arrays = make_simple_threshold_clusters(array_of_my_types,
                                                           my_thresholding_criteria)
