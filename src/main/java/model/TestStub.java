
/**
 * 
 */
package model;

import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.util.ids.DataClayInstanceID;
import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;
import es.bsc.dataclay.util.ids.MetaClassID;
import es.bsc.dataclay.util.ids.ObjectID;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 */
public interface TestStub {

	/**
	 * @brief Delete persistent from stub.
	 */
	void deletePersistent();

	/**
	 * @brief Get ID in string format from stub.
	 * @return ID of the persistent object in string format
	 */
	String getID();

	/**
	 * @brief Make persistent from stub.
	 * @param alias
	 *            alias for the persistent object
	 */
	void makePersistent(final String alias);


	/**
	 * @brief Make persistent from stub.
	 * @param optBackendID destination backend
	 */
	void makePersistent(final BackendID optBackendID);
	
	/**
	 * @brief Make persistent from stub.
	 */
	void makePersistent();

	void sessionDetach();
	void setObjectReadOnly();

	BackendID newReplica(final BackendID optionalBackendID);
	BackendID newReplica(final BackendID optionalBackendID, final boolean recursive);
	BackendID newReplica();

	Set<BackendID> getAllLocations();
	ObjectID getObjectID();
	MetaClassID getMetaClassID();
	BackendID getHint();

	void federate(final DataClayInstanceID extDataClayID, final boolean recursive);

	/**
	 * Get alias
	 * @return the alias of the object
	 */
	String getAlias();

	/**
	 * Set the alias of the object
	 * @param alias the alias of the object
	 */
	void setAlias(String alias);

	/**
	 * @return the original object id in case of new version
	 */
	ObjectID getOriginalObjectID();

	/**
	 *
	 * @param newOriginalObjectID
	 *            the original object id  to set
	 */
	void setOriginalObjectID(final ObjectID newOriginalObjectID);

	/**
	 *
	 * @return origin location of the object or null if current is original
	 */
	ExecutionEnvironmentID getOriginLocation();

	/**
	 * Set origin location of the object
	 * @param originLocation origin location to set
	 */
	void setOriginLocation(ExecutionEnvironmentID originLocation);

	/**
	 * Get all replica locations
	 * @return Replica locations
	 */
	Set<ExecutionEnvironmentID> getReplicaLocations();

	/**
	 * Set replica locations
	 * @param replicaLocations replica locations to set
	 */
	void setReplicaLocations(Set<ExecutionEnvironmentID> replicaLocations);

	/**
	 * Add replica location
	 * @param replicaLocation replica location to add
	 */
	void addReplicaLocations(ExecutionEnvironmentID replicaLocation);

}
