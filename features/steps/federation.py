from steps.steps import *

@given('"{user_name}" registers external dataClay named "{external_dc_name}" with hostname "{host}" and port {port}')
def step_impl(context, user_name, external_dc_name, host, port):
    """
    Register external dataClay
    :param context: feature context
    :param docker_compose_extra_path: docker-compose to use for start
    :param user_name: user name
    :type user_name: string
    :param external_dc_name: name of external dc
    :type external_dc_name: string
    :param host: host of external dc
    :type host: string
    :param port: port of external dc
    :type host: int
    :return: None
    """
    test_user = get_or_create_user(user_name)
    from dataclay import api
    external_dc_id = api.register_dataclay(host, port)
    test_user.user_objects[f"external-dc-{external_dc_name}"] = external_dc_id

@given('"{user_name}" imports models in namespace "{namespace}" from dataClay named "{external_dc_name}"')
def step_impl(context, user_name, namespace, external_dc_name):
    """
    Import models from external dataClay namespace
    :param context: feature context
    :param docker_compose_extra_path: docker-compose to use for start
    :param user_name: user name
    :type user_name: string
    :param namespace: namespace to import
    :type namespace: string
    :param external_dc_name: name of external dc
    :type external_dc_name: string
    :return: None
    """
    test_user = get_or_create_user(user_name)
    external_dc_id = test_user.user_objects[f"external-dc-{external_dc_name}"]
    from dataclay import api
    api.import_models_from_external_dataclay(namespace, external_dc_id)

@given('"{user_name}" federates object to dataClay "{external_dc_name}"')
def step_impl(context, external_dc_name):
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
