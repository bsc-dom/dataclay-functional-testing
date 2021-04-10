package model;

import es.bsc.dataclay.DataClayObject;

public class NodeB extends DataClayObject implements NodeB_Stub {
	private NodeA_Stub NodeA;

	public NodeB() {

	}

	@Override
	public void setNodeA(NodeA_Stub newNodeA) {
		NodeA = newNodeA;
	}

	@Override
	public NodeA_Stub getNodeA() {
		return this.NodeA;
	}
}
