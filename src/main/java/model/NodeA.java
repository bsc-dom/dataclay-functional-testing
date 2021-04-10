package model;

import es.bsc.dataclay.DataClayObject;

public class NodeA extends DataClayObject implements NodeA_Stub {
	private NodeB_Stub NodeB;

	public NodeA() {

	}

	@Override
	public void setNodeB(NodeB_Stub newNodeB) {
		NodeB = newNodeB;
	}

	@Override
	public NodeB_Stub getNodeB() {
		return this.NodeB;
	}
}
