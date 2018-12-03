#define SkimmingSR_cxx
#include "SkimmingSR.h"
#include <TH2.h>
#include <TStyle.h>
#include <TCanvas.h>
#include <iostream>
#include <vector>
#include <cstring>
#include <string>
#include <fstream>

using namespace std;

int main(int argc, char* argv[])
{

  if (argc < 2) {
    cerr << "Please give 3 arguments " << "runList " << " " << "outputFileName" << " " << "dataset" << endl;
    return -1;
  }
  /*
   For example:
   ./skimmingSR smallrunList.txt ouFile.root TTJets_SingleLeptFromTbar
inputFileList=smallrunList.txt
outFileName=ouFile.root
data=TTJets_SingleLeptFromTbar

*/  
  const char *inputFileList = argv[1];
  const char *outFileName   = argv[2];
  const char *data          = argv[3];

  SkimmingSR ana(inputFileList, outFileName, data);
  cout << "dataset " << data << " " << endl;

  ana.EventLoop(data,inputFileList);

  return 0;
}

void SkimmingSR::EventLoop(const char *data,const char *inputFileList) {
  if (fChain == 0) return;
  std::cout<<" eventloop starts "<<endl;
  //*AR:181128-fChain->GetEntriesFast() returns the number of entries in the entire chain (all n files included in chain)
  Long64_t nentries = fChain->GetEntriesFast(); //number of entries/events
  cout << "nentries " << nentries << endl;
  cout << "Analyzing dataset " << data << " " << endl;
  //  fChain->SetMakeClass(1);
  TBranch        *b_RunNum=0;
  UInt_t          RunNum;

  TBranch        *b_HT=0;
  Double_t        HT;  

  TBranch        *b_MHT=0;
  Double_t        MHT;  

  //  Double_t        madHT;

  //  TBranch        *b_madHT=0;

  fChain->SetBranchAddress("RunNum", &RunNum, &b_RunNum);
  fChain->SetBranchStatus("RunNum", 1);
  
  fChain->SetBranchAddress("HT", &HT, &b_HT);
  fChain->SetBranchStatus("HT", 1);

  fChain->SetBranchAddress("MHT", &MHT, &b_MHT);
  fChain->SetBranchStatus("MHT", 1);

  //  fChain->SetBranchAddress("madHT", &madHT, &b_madHT);
  //  fChain->SetBranchStatus("madHT",1);

  Long64_t nbytes = 0, nb = 0;
  int decade = 0;
  //  TTree *newtree = fChain->GetTree()->CloneTree(0);
  //*AR: copies a subset of tree to new tree
  fChain->LoadTree(0);
  TTree *newtree = fChain->GetTree()->CloneTree(0);
  // TTree *newtree = fChain->GetTree()->CopyTree("HT>200. && MHT>200.");
  string s_data = data;
  int PassedEntry=0;  

  for (Long64_t jentry=0; jentry<nentries;jentry++) {
    // ==============print number of events done == == == == == == == =
    double progress = 10.0 * jentry / (1.0 * nentries);
    int k = int (progress);
    if (k > decade)
      cout << 10 * k << " %" <<endl;
    decade = k;
    Int_t ientry = LoadTree(jentry);
    if (ientry < 0) break;
    //*AR: following updates to nb and nbytes are must, otherwise, LoadTree doesn't know what to do once jentry gets to be larger than the  number of entries in the first file in the chain. That means values from last entry in first file, are repeated for all entries in all files after first file. 
    nb = fChain->GetEntry(jentry);   nbytes += nb;

    //    std::cout<<" ientry "<<ientry<<endl;
    //    fChain->GetTree();  
    fChain->GetTree()->GetEntry(jentry);
    h_selectBaselineYields_->Fill(0);
  /*  
    if(jentry==0){
      newtree = fChain->GetTree()->CloneTree(0); 
    }
*/
    //    std::cout<<" jentry "<<jentry<<" run "<<RunNum<<" HT "<<HT<<" MHT "<<MHT<<endl;
    if(MHT<200.)
      continue;
    h_selectBaselineYields_->Fill(1);

    if(HT<200.)
      continue;
    h_selectBaselineYields_->Fill(2);


    if(s_data.find("Tbar_SingleLep")!=string::npos || s_data.find("T_SingleLep")!=string::npos || s_data.find("DiLept")!=string::npos){
      Double_t madHTcut=600;   
    }
    h_selectBaselineYields_->Fill(3);
    PassedEntry++; 
    //    std::cout<<" Evtnum "<<EvtNum<<" run "<<RunNum<<" ht "<<HT<<" mht "<<MHT<<" mad "<<madHT<<endl;
    //    fChain->GetTree()->GetEntry(jentry);
    //    std::cout<<" jentry "<<jentry<<" Jets->size() "<<Jets->size()<<endl;
    //    Long64_t ientry = LoadTree(jentry);
    //    if (ientry < 0) break;
    //    nb = b_EvtNum->GetEntry(jentry); nbytes += nb;    
    //----------------- for signal samples --------------------
    //    h_selectBaselineYields_->Fill(0);
    /*
    if(s_data=="TTJets_SingleLeptFromTbar" || s_data=="TTJets_SingleLeptFromT" || s_data=="DiLept"){
      if(madHT>600){
	std::cout<<" jentry "<<jentry<<" madHT "<<madHT<<" skipped event "<<endl; 
	continue;//putting a cut on madHT for SingleLept and DiLept samples of TTbar. Do not use for other samples.
      }
    }
    */

    //end of select skimming parameters
    newtree->Fill();
    
  } // loop over entries
  
  //  newtree->AutoSave();
}

TLorentzVector SkimmingSR::getBestPhoton(){
  int bestPhoIndx=-100;
  TLorentzVector v1;
  vector<TLorentzVector> goodPho;
  /*
  for(int iPhoton=0;iPhoton<Photons->size();iPhoton++){
    if( ((*Photons_fullID)[iPhoton]) && ((*Photons_hasPixelSeed)[iPhoton]<0.001) ) goodPho.push_back( (*Photons)[iPhoton] );
  }

  if(goodPho.size()==0) return v1;
  else if(goodPho.size()==1) return goodPho[0];
  else{
    for(int i=0;i<goodPho.size();i++){
      if(i==0) bestPhoIndx=0;
      else if(goodPho[bestPhoIndx].Pt() < goodPho[i].Pt()) bestPhoIndx=i;
    }
    return goodPho[bestPhoIndx];
  }
*/
}

