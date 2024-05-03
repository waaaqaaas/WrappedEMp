const EmpressToken = artifacts.require("EmpressToken");
const WrappedEMP = artifacts.require("WrappedEMP");

module.exports = function (deployer) {
  deployer.deploy(EmpressToken);
  deployer.deploy(WrappedEMP, EmpressToken.address);
};
