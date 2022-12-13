import Dates
import XMLDict

struct OrbitState 
    time::Dates.DateTime
    position::Array{Float64,1} 
    velocity::Array{Float64,1}
end 


function parse_orbit_state_sentinel1(xml_element) 
    time = Dates.DateTime(xml_element["UTC"][5:27], "yyyy-mm-ddTHH:MM:SS.sss")
    
    x = parse(Float64, xml_element["X"][""])
    y = parse(Float64, xml_element["Y"][""])
    z = parse(Float64, xml_element["Z"][""])
    position = [x,y,z]
    
    vx = parse(Float64, xml_element["VX"][""])
    vy = parse(Float64, xml_element["VY"][""])
    vz = parse(Float64, xml_element["VZ"][""])
    velocity = [vx,vy,vz]
    
    #convert OSV to the data type as in Orbit State
    return OrbitState(time, position, velocity)
end


function precise_orbit_sentinel1(path)

    # Load data as dict
    doc = open(f->read(f, String), path)
    pod_dict = XMLDict.xml_dict(doc)

    # Access orbit state vectors
    state_vectors_dict = pod_dict["Earth_Explorer_File"]["Data_Block"]["List_of_OSVs"]["OSV"];
    orbit_state_array = [parse_orbit_state_sentinel1(xml_element) for xml_element in state_vectors_dict]
    return orbit_state_array
end