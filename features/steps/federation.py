from steps.steps import *

@given('"{user_name}" registers external dataClay with hostname "{host}" and port {port}')
@when('"{user_name}" registers external dataClay with hostname "{host}" and port {port}')
@then('"{user_name}" registers external dataClay with hostname "{host}" and port {port}')
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
@when('"{user_name}" imports models in namespace "{namespace}" from dataClay at hostname "{host}" and port {port}')
@then('"{user_name}" imports models in namespace "{namespace}" from dataClay at hostname "{host}" and port {port}')
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


@given('"{user_name}" gets ID of external dataClay at hostname "{ext_dc_host}" and port {ext_dc_port} into "{ext_dc_variable}" variable')
@when('"{user_name}" gets ID of external dataClay at hostname "{ext_dc_host}" and port {ext_dc_port} into "{ext_dc_variable}" variable')
@then('"{user_name}" gets ID of external dataClay at hostname "{ext_dc_host}" and port {ext_dc_port} into "{ext_dc_variable}" variable')
def step_impl(context, user_name, ext_dc_host, ext_dc_port, ext_dc_variable):
    test_user = get_or_create_user(user_name)
    from dataclay import api
    dataclay_id = api.get_dataclay_id(ext_dc_host, int(ext_dc_port))
    test_user.user_objects[ext_dc_variable] = dataclay_id

@given('"{user_name}" gets ID of "{backend_name}" backend from external dataClay with ID "{ext_dc_id_var}" into "{ext_backend_id_var}" variable')
@when('"{user_name}" gets ID of "{backend_name}" backend from external dataClay with ID "{ext_dc_id_var}" into "{ext_backend_id_var}" variable')
@then('"{user_name}" gets ID of "{backend_name}" backend from external dataClay with ID "{ext_dc_id_var}" into "{ext_backend_id_var}" variable')
def step_impl(context, user_name, backend_name, ext_dc_id_var, ext_backend_id_var):
    test_user = get_or_create_user(user_name)
    ext_dc_id = test_user.user_objects[ext_dc_id_var]
    from dataclay import api
    dataclay_id = api.get_external_backend_id_by_name(backend_name, ext_dc_id)
    test_user.user_objects[ext_backend_id_var] = dataclay_id

@given('"{user_name}" federates "{obj_ref}" object to dataClay with ID "{ext_dc_id}"')
@when('"{user_name}" federates "{obj_ref}" object to dataClay with ID "{ext_dc_id}"')
@then('"{user_name}" federates "{obj_ref}" object to dataClay with ID "{ext_dc_id}"')
def step_impl(context, user_name, obj_ref, ext_dc_id):
    test_user = get_or_create_user(user_name)
    dataclay_id = test_user.user_objects[ext_dc_id]
    obj = test_user.user_objects[obj_ref]
    obj.federate(dataclay_id)


@given('"{user_name}" federates "{obj_ref}" object to external dataClay backend with ID "{ext_dc_backend_id_var}"')
@when('"{user_name}" federates "{obj_ref}" object to external dataClay backend with ID "{ext_dc_backend_id_var}"')
@then('"{user_name}" federates "{obj_ref}" object to external dataClay backend with ID "{ext_dc_backend_id_var}"')
def step_impl(context, user_name, obj_ref, ext_dc_backend_id_var):
    test_user = get_or_create_user(user_name)
    ext_dc_backend_id = test_user.user_objects[ext_dc_backend_id_var]
    obj = test_user.user_objects[obj_ref]
    obj.federate_to_backend(ext_dc_backend_id)

@given('"{user_name}" federates "{obj_ref}" object with recursive = "{recursive}" to external dataClay backend with ID "{ext_dc_backend_id_var}"')
@when('"{user_name}" federates "{obj_ref}" object with recursive = "{recursive}" to external dataClay backend with ID "{ext_dc_backend_id_var}"')
@then('"{user_name}" federates "{obj_ref}" object with recursive = "{recursive}" to external dataClay backend with ID "{ext_dc_backend_id_var}"')
def step_impl(context, user_name, obj_ref, recursive, ext_dc_backend_id_var):
    test_user = get_or_create_user(user_name)
    ext_dc_backend_id = test_user.user_objects[ext_dc_backend_id_var]
    obj = test_user.user_objects[obj_ref]
    obj.federate_to_backend(ext_dc_backend_id, recursive=bool(recursive))


@given('"{user_name}" unfederates "{obj_ref}" object with dataClay with ID "{ext_dc_id}"')
@when('"{user_name}" unfederates "{obj_ref}" object with dataClay with ID "{ext_dc_id}"')
@then('"{user_name}" unfederates "{obj_ref}" object with dataClay with ID "{ext_dc_id}"')
def step_impl(context, user_name, obj_ref, ext_dc_id):
    test_user = get_or_create_user(user_name)
    dataclay_id = test_user.user_objects[ext_dc_id]
    obj = test_user.user_objects[obj_ref]
    obj.unfederate(ext_dataclay_id=dataclay_id)
