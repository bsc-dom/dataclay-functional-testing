from steps.steps import *

@given('"{user_name}" registers external dataClay with hostname "{host}" and port {port}')
def step_impl(context, user_name, host, port):
    """
    Register external dataClay
    :param context: feature context
    :param docker_compose_extra_path: docker-compose to use for start
    :param user_name: user name
    :type user_name: string
    :param host: host of external dc
    :type host: string
    :param port: port of external dc
    :type host: int
    :return: None
    """
    test_user = get_or_create_user(user_name)
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network,
                f"RegisterDataClay {host} {port}")


@given('"{user_name}" imports models in namespace "{namespace}" from dataClay at hostname "{host}" and port {port}')
def step_impl(context, user_name, namespace, host, port):
    """
    Import models from external dataClay namespace
    :param context: feature context
    :param user_name: user name
    :type user_name: string
    :param namespace: namespace to import
    :type namespace: string
    :param host: host of external dc
    :type host: string
    :param port: port of external dc
    :type host: int
    :return: None
    """
    test_user = get_or_create_user(user_name)
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network,
                f"ImportModelsFromExternalDataClay {host} {port} {namespace}")

@given('"{user_name}" gets ID of external dataClay named "{external_dc_name}" at hostname "{host}" and port {port}')
def step_impl(context, user_name, external_dc_name, host, port):
    """
    Get dataclay id
    :param context: feature context
    :param user_name: user name
    :type user_name: string
    :param external_dc_name: external dc name
    :type external_dc_name: string
    :param host: host of external dc
    :type host: string
    :param port: port of external dc
    :type host: int
    :return: None
    """
    test_user = get_or_create_user(user_name)
    from dataclay import api
    external_dc_id = api.get_dataclay_id(host, int(port))
    test_user.user_objects[f"external-dc-{external_dc_name}"] = external_dc_id

@given('"{user_name}" federates object to dataClay "{external_dc_name}"')
def step_impl(context, user_name, external_dc_name):
    """ Run make persistent
        :param context: the current feature context
        :type context
        :param user_name: user name
        :type user_name: string
    """
    test_user = get_or_create_user(user_name)
    external_dc_id = test_user.user_objects[f"external-dc-{external_dc_name}"]
    person = test_user.user_objects["person"]
    person.federate(external_dc_id, True)
