

function find_annotation_sentinel1_test()
    ## Arrange
    files = ["s1a-iw1-slc-vh-20220918t074922-20220918t074947-045056-056232-001.xml",
        "s1a-iw1-slc-vv-20220918t074922-20220918t074947-045056-056232-004.xml",
        "s1a-iw2-slc-vh-20220918t074920-20220918t074945-045056-056232-002.xml",
        "s1a-iw2-slc-vv-20220918t074920-20220918t074945-045056-056232-005.xml",
        "s1a-iw3-slc-vh-20220918t074921-20220918t074946-045056-056232-003.xml",
        "s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.xml"]
    
    ## Act
    name = SARProcessing._find_file_sentinel1(files,SARProcessing.VH, 2) 

    ## Assert

    testOk = name == "s1a-iw2-slc-vh-20220918t074920-20220918t074945-045056-056232-002.xml"
    
    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("name: ", name)
    end
    return testOk
end

function find_data_sentinel1_test()
    ## Arrange
    files = ["s1a-iw1-slc-vh-20220918t074922-20220918t074947-045056-056232-001.tiff",
    "s1a-iw1-slc-vv-20220918t074922-20220918t074947-045056-056232-004.tiff",
    "s1a-iw2-slc-vh-20220918t074920-20220918t074945-045056-056232-002.tiff",
    "s1a-iw2-slc-vv-20220918t074920-20220918t074945-045056-056232-005.tiff",
    "s1a-iw3-slc-vh-20220918t074921-20220918t074946-045056-056232-003.tiff",
    "s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff"]
    
    ## Act
    name = SARProcessing._find_file_sentinel1(files,SARProcessing.VV, 1) 

    ## Assert

    testOk = name == "s1a-iw1-slc-vv-20220918t074922-20220918t074947-045056-056232-004.tiff"
    
    ## Debug
    if !testOk
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("name: ", name)
    end
    return testOk
end


function load_sentinel1slc_test()
    ## Arrange
    
    ## Act
    image = SARProcessing.load_sentinel1slc(SLC_SAFE_PATH,SARProcessing.VH, 1,SLC_SUBSET_WINDOW) 
    
    ## Assert
    data = SARProcessing.get_data(image)
    polarisation = SARProcessing.get_polarisation(image)
    deramped = SARProcessing.is_deramped(image)

    test_ok = typeof(data)== Matrix{ComplexF64}
    test_ok &= polarisation == SARProcessing.VH
    test_ok &= deramped==false
    test_ok &= image.index_start[1] == SLC_SUBSET_WINDOW[1][1] && image.index_start[2] == SLC_SUBSET_WINDOW[2][1]
    
    ## Debug
    if !test_ok
        println("Debug info: ", String(Symbol(constructOrbitState)))
        println("typeof(data): ", typeof(data))
        println("polarisation: ", polarisation)
        println("deramped: ", deramped)
        println("image.index_start: ", image.index_start)
    end
    return test_ok
end

@testset "Sentinel1/FileIo.jl" begin
    ####### actual tests ###############
    @test find_annotation_sentinel1_test()
    @test find_data_sentinel1_test()
    if ispath(SLC_SAFE_PATH) 
        @test load_sentinel1slc_test()
    end
end



