#ifndef SkimmingSR_H
#define SkimmingSR_H

#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include "NtupleVariables.h"
#include "TH1F.h"
#include "TH2.h"
#include <TProfile.h>
#include "TFile.h"
#include "TLorentzVector.h"
#include "TDirectory.h"

class SkimmingSR : public NtupleVariables{

 public:
  SkimmingSR(const TString &inputFileList="foo.txt", const char *outFileName="histo.root",const char *dataset="data");
  ~SkimmingSR();
  Bool_t   FillChain(TChain *chain, const TString &inputFileList);
  Long64_t LoadTree(Long64_t entry);
  void     EventLoop(const char *,const char *);
  void     BookHistogram();
  TLorentzVector getBestPhoton();
  //  double ht_();
  //Variables defined
  TH1F *h_selectBaselineYields_;
  TH1D *h_met0,*h_mht0,*h_st0,*h_ht0,*h_nj0,*h_nhadj,*h_phopt0;
  TFile *oFile;
  
};
#endif

#ifdef SkimmingSR_cxx

void SkimmingSR::BookHistogram() {
  TH1::SetDefaultSumw2(1);
  //  char hname[200], htit[200];
  //  double xlow = 0.0,  xhigh = 2000.0;
  //  int nbins = 2000;
  char name[100],title[100];
  h_selectBaselineYields_ = new TH1F("selectBaselineYields_","selectBaselineYields_",10,-0.5,9.5);
  h_met0 = new TH1D("met0","MET before any selection",500,0,5000);
  h_mht0 = new TH1D("mht0","MHT before any selection",500,0,5000);
  h_st0 = new TH1D("st0","ST after best Photon selection",500,0,5000);
  h_ht0 = new TH1D("ht0","HT before any selection",500,0,5000);
  h_nj0 = new TH1D("nj0","NJ before any selection",50,0,50);
  h_nhadj = new TH1D("nhadj0","nHadjets after best Photon selection",50,0,50);
  h_phopt0 = new TH1D("phopt0","all photons Pt before any selection",500,0,5000);
}


SkimmingSR::SkimmingSR(const TString &inputFileList, const char *outFileName, const char* dataset) {
  string nameData=dataset;//vvv
  //  TChain *tree = new TChain("PreSelection");
  TChain *tree = new TChain("TreeMaker2/PreSelection");
  //if(nameData=="signalH") tree = new TChain("TreeMaker2/PreSelection");//vvv
  if( ! FillChain(tree, inputFileList) ) {
    std::cerr << "Cannot get the tree " << std::endl;
  } else {
    std::cout << "Initiating analysis of dataset " << dataset << std::endl;
  }

  //if(nameData!="signalH") nameData="BG";
  //cout<<"Treating the input files as "<<nameData<<" for setting tree branches"<<endl;
  NtupleVariables::Init(tree,nameData);

  BookHistogram();
  char outflName[100];
  sprintf(outflName,"%s_%s",dataset,outFileName);
  oFile = new TFile(outflName, "recreate");
}

Bool_t SkimmingSR::FillChain(TChain *chain, const TString &inputFileList) {

  ifstream infile(inputFileList, ifstream::in);
  std::string buffer;

  if(!infile.is_open()) {
    std::cerr << "** ERROR: Can't open '" << inputFileList << "' for input" << std::endl;
    return kFALSE;
  }

  std::cout << "TreeUtilities : FillChain " << std::endl;
  while(1) {
    infile >> buffer;
    if(!infile.good()) break;
    //std::cout << "Adding tree from " << buffer.c_str() << std::endl;                                                              
    chain->Add(buffer.c_str());
  }
  std::cout << "No. of Entries in this tree : " << chain->GetEntries() << std::endl;
  return kTRUE;
}

Long64_t SkimmingSR::LoadTree(Long64_t entry) {
  // Set the environment to read one entry                                                                                          
  if (!fChain) return -5;
  Long64_t centry = fChain->LoadTree(entry);
  if (centry < 0) return centry;
  if (!fChain->InheritsFrom(TChain::Class()))  return centry;
  TChain *chain = (TChain*)fChain;
  if (chain->GetTreeNumber() != fCurrent) {
    fCurrent = chain->GetTreeNumber();
    //    Notify();
  }
  return centry;
}
//SkimmingSR::ht_() { return HT; }

SkimmingSR::~SkimmingSR() { 

  if (!fChain) return;
  delete fChain->GetCurrentFile();
  oFile->cd();
  h_selectBaselineYields_->Write();
  h_met0->Write();
  h_mht0->Write();
  h_ht0->Write();
  h_nj0->Write();
  h_phopt0->Write();
  h_st0->Write();
  h_nhadj->Write();

  oFile->Write();
  oFile->Close();

}

#endif

