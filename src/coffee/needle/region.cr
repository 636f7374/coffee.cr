module Coffee::Needle
  # References: https://www.cloudflarestatus.com/

  module Region
    enum Flag
      Africa
      Asia
      Europe
      LatinAmerica_TheCaribbean
      MiddleEast
      NorthAmerica
      Oceania
    end

    Africa = [
      IATA::TNR, IATA::CPT, IATA::CMN, IATA::DAR, IATA::JIB, IATA::DUR, IATA::JNB, IATA::KGL,
      IATA::LOS, IATA::LAD, IATA::MPM, IATA::MBA, IATA::MRU, IATA::RUN,
    ]

    Asia = [
      IATA::BLR, IATA::BKK, IATA::BWN, IATA::CEB, IATA::CTU, IATA::MAA, IATA::CGP, IATA::CKG,
      IATA::CMB, IATA::DAC, IATA::SZX, IATA::FUO, IATA::FOC, IATA::CAN, IATA::HGH, IATA::HAN,
      IATA::HNY, IATA::SGN, IATA::HKG, IATA::HYD, IATA::ISB, IATA::CGK, IATA::TNA, IATA::KHI,
      IATA::KTM, IATA::CCU, IATA::KUL, IATA::LHE, IATA::NAY, IATA::LYA, IATA::MFM, IATA::MLE,
      IATA::MNL, IATA::BOM, IATA::NAG, IATA::NNG, IATA::DEL, IATA::KIX, IATA::PNH, IATA::TAO,
      IATA::ICN, IATA::SHA, IATA::SHE, IATA::SJW, IATA::SIN, IATA::SZV, IATA::TPE, IATA::PBH,
      IATA::TSN, IATA::NRT, IATA::ULN, IATA::VTE, IATA::WUH, IATA::WUX, IATA::XIY, IATA::EVN,
      IATA::CGO, IATA::CSX,
    ]

    Europe = [
      IATA::AMS, IATA::ATH, IATA::BCN, IATA::BEG, IATA::TXL, IATA::BRU, IATA::OTP, IATA::BUD,
      IATA::KIV, IATA::CPH, IATA::ORK, IATA::DUB, IATA::DUS, IATA::EDI, IATA::FRA, IATA::GVA,
      IATA::GOT, IATA::HAM, IATA::HEL, IATA::IST, IATA::KBP, IATA::LIS, IATA::LHR, IATA::LUX,
      IATA::MAD, IATA::MAN, IATA::MRS, IATA::MXP, IATA::DME, IATA::MUC, IATA::LCA, IATA::OSL,
      IATA::CDG, IATA::PRG, IATA::KEF, IATA::RIX, IATA::FCO, IATA::LED, IATA::SOF, IATA::ARN,
      IATA::TLL, IATA::SKG, IATA::VIE, IATA::VNO, IATA::WAW, IATA::ZAG, IATA::ZRH,
    ]

    LatinAmerica_TheCaribbean = [
      IATA::ARI, IATA::ASU, IATA::BOG, IATA::EZE, IATA::CWB, IATA::FOR, IATA::GUA, IATA::LIM,
      IATA::MDE, IATA::PTY, IATA::POA, IATA::UIO, IATA::GIG, IATA::GRU, IATA::SCL, IATA::CUR,
      IATA::GND, IATA::TGU,
    ]

    MiddleEast = [
      IATA::AMM, IATA::BGW, IATA::GYD, IATA::BEY, IATA::DOH, IATA::DXB, IATA::KWI, IATA::BAH,
      IATA::MCT, IATA::ZDM, IATA::RUH, IATA::TLV,
    ]

    NorthAmerica = [
      IATA::IAD, IATA::ATL, IATA::BOS, IATA::BUF, IATA::YYC, IATA::CLT, IATA::ORD, IATA::CMH,
      IATA::DFW, IATA::DEN, IATA::DTW, IATA::HNL, IATA::IAH, IATA::IND, IATA::JAX, IATA::MCI,
      IATA::LAS, IATA::LAX, IATA::MFE, IATA::MEM, IATA::MEX, IATA::MIA, IATA::MSP, IATA::MGM,
      IATA::YUL, IATA::BNA, IATA::EWR, IATA::ORF, IATA::OMA, IATA::PHL, IATA::PHX, IATA::PIT,
      IATA::PAP, IATA::PDX, IATA::QRO, IATA::RIC, IATA::SMF, IATA::SLC, IATA::SAN, IATA::SJC,
      IATA::YXE, IATA::SEA, IATA::STL, IATA::TPA, IATA::YYZ, IATA::YVR, IATA::TLH, IATA::YWG,
    ]

    Oceania = [IATA::ADL, IATA::AKL, IATA::BNE, IATA::MEL, IATA::NOU, IATA::PER, IATA::SYD]

    def self.parse?(value : String)
      _flag = Flag.parse? value
      return unless _flag

      case _flag
      when .africa?
        Africa
      when .asia?
        Asia
      when .europe?
        Europe
      when .latin_america_the_caribbean?
        LatinAmerica_TheCaribbean
      when .middle_east?
        MiddleEast
      when .north_america?
        NorthAmerica
      when .oceania?
        Oceania
      end
    end
  end
end
