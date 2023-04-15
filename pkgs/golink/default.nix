{ lib
, buildGo120Module
, fetchFromGitHub
,
}:
buildGo120Module rec {
  pname = "golink";
  version = "b9fdc2dcab237acd07ec628435a7864201b7e839";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "golink";
    rev = "${version}";
    sha256 = "sha256-G0GBqSYVXD27kM0+h0J0cxqcico/QpUDDqf5v7op5Kg=";
  };

  vendorSha256 = "sha256-cOpBNJCn3+tkPix3px4u7OhlS+hTdDPvOCuz/J+WQ9g=";

  meta = with lib; {
    homepage = "https://github.com/tailscale/golink";
    description = " A private shortlink service for tailnets";
    license = licenses.bsd3;
  };
}
