import Dates
import EzXML
import XMLDict

#immutable data struct 
struct OrbitState 
    time::Dates.DateTime
    position::Array{Float64,1} 
    velocity::Array{Float64,1}
end 

function parse_orbit_state(xmlelement) 
    time = Dates.DateTime(xmlelement["UTC"][5:27], "yyyy-mm-ddTHH:MM:SS.sss")
    
    x = parse(Float64, xmlelement["X"][""])
    y = parse(Float64, xmlelement["Y"][""])
    z = parse(Float64, xmlelement["Z"][""])
    position = [x,y,z]
    
    vx = parse(Float64, xmlelement["VX"][""])
    vy = parse(Float64, xmlelement["VY"][""])
    vz = parse(Float64, xmlelement["VZ"][""])
    velocity = [vx,vy,vz]
    
    #convert OSV to the data type as in Orbit State
    return OrbitState(time, position, velocity)
end

path = "/Users/igaszczesniak/Desktop/SARProcessing/S1A_OPER_AUX_POEORB_20221119T081845.EOF"

function precise_orbit(path)

    # Load data as dict
    doc = EzXML.readxml(path)
    pod_dict = XMLDict.xml_dict(doc)

    # Acces orbit state vectors
    state_vectors_dict = pod_dict["Earth_Explorer_File"]["Data_Block"]["List_of_OSVs"]["OSV"];
    orbitstatearray = [parse_orbit_state(xmlelement) for xmlelement in state_vectors_dict]
    
end