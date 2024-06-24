#GMAT_BRANCH = master
GMAT_BRANCH = dev
#GMAT__PLUGIN_BRANCH = master
GMAT__PLUGIN_BRANCH = dev
GMAT_MASTER_BRANCH = master
GMAT_OFI_BRANCH = master
GMAT_HOME = C:/Users/gsfc580gmatbuild/Documents
GMAT_DIR = $(GMAT_HOME)/GmatDevelopment
GMAT_SRC_BASE_DIR = $(GMAT_DIR)/src/base
GMAT_SRC_GUI_DIR = $(GMAT_DIR)/src/gui
GMAT_PLUGIN_DIR = $(GMAT_HOME)/GmatPlugins/code
GMAT_OFI_DIR = $(GMAT_HOME)/OFI
GMAT_BUILD_DIR = $(GMAT_DIR)/build/windows-VS2017-CMake-64
GMAT_INSTALL_DIR = $(GMAT_DIR)/GMAT-R2020a-Windows-x64
GMAT_BIN_DIR = $(GMAT_DIR)/application/bin
GMAT_MATLAB_CINTF_DIR = $(GMAT_DIR)/application/matlab/libCInterface
GMAT_PLUGIN_BIN_DIR = $(GMAT_DIR)/application/plugins
GMAT_PROPRIETARY_BIN_DIR = $(GMAT_DIR)/application/plugins/proprietary
GMAT_CAPI_PLUGIN_DIR = $(GMAT_DIR)/plugins/CInterfacePlugin
GMAT_CAPI_PLUGIN_SRC_DIR = $(GMAT_CAPI_PLUGIN_DIR)/src
GMAT_CAPI_PLUGIN_DOCS_DIR = $(GMAT_CAPI_PLUGIN_DIR)/doc
GMAT_DOC_DIR = $(GMAT_DIR)/doc
GMAT_HELP_BUILD_DIR = $(GMAT_DOC_DIR)/help
NETWORK_DIR = Y:
DESTINATION_DIR  = $(NETWORK_DIR)/Builds/windows/VS2017_build_64
BUILD_DATE = ` date "+%Y-%m-%d" `
DAILY_DESTINATION_DIR = $(DESTINATION_DIR)/$(BUILD_DATE)
DAILY_MATLAB_DEST_DIR = $(DAILY_DESTINATION_DIR)/matlab
DAILY_MATLAB_CINTF_DEST_DIR = $(DAILY_DESTINATION_DIR)/matlab/libCInterface
DAILY_EXE_DEST_DIR = $(DAILY_DESTINATION_DIR)/bin
DAILY_PLUGINS_DEST_DIR = $(DAILY_DESTINATION_DIR)/plugins
DAILY_PROPRIETARY_DEST_DIR = $(DAILY_DESTINATION_DIR)/plugins/proprietary
DAILY_DOCS_DEST_DIR = $(DAILY_DESTINATION_DIR)/docs
DAILY_HELP_DEST_DIR = $(DAILY_DOCS_DEST_DIR)/help
LATEST_BUILD_DIR = $(DESTINATION_DIR)/LatestCompleteVersion
LATEST_BIN_BUILD_DIR = $(LATEST_BUILD_DIR)/bin
LATEST_DOCS_BUILD_DIR = $(NETWORK_DIR)/Builds/DevDocs

# compiles the latest build
all: 
	cd $(GMAT_BUILD_DIR); \
	cmake . > cmakegenerate.log 2>&1 && cmake --build . --config Release -- //m //fl ; \
	cmake --build . --target INSTALL --config Release -- //fl ;
	

# cleans up the compiled source code and docs files
clean:
	cd $(GMAT_BUILD_DIR); \
	cmake --build . --target clean --config Release -- //fl ;\
	cd $(GMAT_HELP_BUILD_DIR) && $(MAKE) clean;\
	rm -rf $(GMAT_INSTALL_DIR);

# checks out the repositories
checkout:
	cd $(GMAT_DIR); git checkout $(GMAT_MASTER_BRANCH); git branch -D $(GMAT_BRANCH); git checkout $(GMAT_BRANCH); git pull "origin" $(GMAT_BRANCH); \
	cd $(GMAT_PLUGIN_DIR); git checkout $(GMAT_PLUGIN_BRANCH); git pull; \
	cd $(GMAT_OFI_DIR); git checkout $(GMAT_OFI_BRANCH); git pull;\

# assembles the latest build, including user help
dist: 
	
	#Copies the latest build to the Dated Build folder
	mkdir -p $(DAILY_DESTINATION_DIR); \
	mkdir -p $(DAILY_EXE_DEST_DIR); \
	mkdir -p $(DAILY_MATLAB_DEST_DIR); \
	mkdir -p $(DAILY_MATLAB_CINTF_DEST_DIR); \
	mkdir -p $(DAILY_PLUGINS_DEST_DIR); \
	mkdir -p $(DAILY_PROPRIETARY_DEST_DIR); \
	mkdir -p $(DAILY_DOCS_DEST_DIR); \
	mkdir -p $(DAILY_HELP_DEST_DIR); \
	cd $(GMAT_BIN_DIR); \
	cp GMAT.exe $(DAILY_EXE_DEST_DIR); \
	cp libGmatBase.dll $(DAILY_EXE_DEST_DIR); \
	cp libCInterface.dll $(DAILY_EXE_DEST_DIR); \
    cp libGmatUtil.dll $(DAILY_EXE_DEST_DIR); 
	cd $(GMAT_MATLAB_CINTF_DIR); \
#	cp interfacewrapper.m $(DAILY_MATLAB_CINTF_DEST_DIR); 
	cd $(GMAT_PLUGIN_BIN_DIR); \
	cp *.dll $(DAILY_PLUGINS_DEST_DIR);
	cd $(GMAT_PROPRIETARY_BIN_DIR); \
	cp *.dll $(DAILY_PROPRIETARY_DEST_DIR);
	cd $(GMAT_HELP_BUILD_DIR); \
	cp help-a4.pdf $(DAILY_HELP_DEST_DIR); \
	cp help-letter.pdf $(DAILY_HELP_DEST_DIR); \
	cp help.html $(DAILY_HELP_DEST_DIR); \
	cp help.chm $(DAILY_HELP_DEST_DIR); \
	cp -r $(GMAT_HELP_BUILD_DIR)/html $(DAILY_HELP_DEST_DIR);  \
	cp -r $(GMAT_HELP_BUILD_DIR)/files $(DAILY_HELP_DEST_DIR); \
    
	#Delete Old LatestCompleteVersion
	rm -rf $(LATEST_BUILD_DIR);\
	
	#Copies the latest install build to the LatestCompleteVersion 
	cd $(GMAT_BUILD_DIR); 
	mkdir -p $(LATEST_BUILD_DIR);
	cp -r $(GMAT_INSTALL_DIR)/* $(LATEST_BUILD_DIR)
	#cp -av "$(NETWORK_DIR)"/Builds/windows/vc_lib/*.dll "$(LATEST_BUILD_DIR)"/bin
	cp -r $(DAILY_HELP_DEST_DIR) $(LATEST_BUILD_DIR)/docs

dist-devdocs:
	rm -rf $(LATEST_DOCS_BUILD_DIR)
	mkdir -p $(LATEST_DOCS_BUILD_DIR)
	cp -r $(GMAT_DOC_DIR)/html/base $(LATEST_DOCS_BUILD_DIR)
	cp -r $(GMAT_DOC_DIR)/html/gui $(LATEST_DOCS_BUILD_DIR)
	cp -r $(GMAT_CAPI_PLUGIN_DOCS_DIR)/capi $(LATEST_DOCS_BUILD_DIR)

check:

# makes the user docs
userdocs:
#	cd  $(GMAT_HELP_BUILD_DIR) && $(MAKE) help
	cd  $(GMAT_HELP_BUILD_DIR) && $(MAKE) help JAVA=C:/Java/bin/java.exe
	
# makes the dev docs
devdocs:
	cd $(GMAT_SRC_BASE_DIR); doxygen;
	cd $(GMAT_SRC_GUI_DIR); doxygen;
	cd $(GMAT_CAPI_PLUGIN_SRC_DIR); doxygen;

