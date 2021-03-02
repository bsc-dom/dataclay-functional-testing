from steps.steps import *


@given('"{user_name}" sets "{obj_ref}" object to be read only')
@when('"{user_name}" sets "{obj_ref}" object to be read only')
@then('"{user_name}" sets "{obj_ref}" object to be read only')
def step_impl(context, user_name, obj_ref):
    #context.person.set_read_only()
    pass

@given('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}" and recursive = "{recursive}"')
@when('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}" and recursive = "{recursive}"')
@then('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}" and recursive = "{recursive}"')
def new_replica_step_impl(context, user_name, obj_ref, backend_name, recursive):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    backend_id = None
    if backend_name != "null":
        from dataclay import api
        backend_id = api.get_backend_id_by_name(backend_name)
    rec = True
    if recursive == "False":
        rec = False
    obj.new_replica(backend_id=backend_id, recursive=rec)

@given('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}"')
@when('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}"')
@then('"{user_name}" calls new replica for object "{obj_ref}" with destination backend named = "{backend_name}"')
def step_impl(context, user_name, obj_ref, backend_name):
    new_replica_step_impl(context, user_name, obj_ref, backend_name, "True")

@given('"{user_name}" calls new replica for object "{obj_ref}"')
@when('"{user_name}" calls new replica for object "{obj_ref}"')
@then('"{user_name}" calls new replica for object "{obj_ref}"')
def step_impl(context, user_name, obj_ref):
    new_replica_step_impl(context, user_name, obj_ref, "null", "True")

@given('"{user_name}" gets id of "{backend_name}" backend into "{var_ref}" variable')
@when('"{user_name}" gets id of "{backend_name}" backend into "{var_ref}" variable')
@then('"{user_name}" gets id of "{backend_name}" backend into "{var_ref}" variable')
def step_impl(context, user_name, backend_name, var_ref):
    test_user = get_or_create_user(user_name)
    from dataclay import api
    backend_id = api.get_backend_id_by_name(backend_name)
    test_user.user_objects[var_ref] = backend_id

@given('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in {num_locations} locations')
@when('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in {num_locations} locations')
@then('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in {num_locations} locations')
def step_impl(context, user_name, obj_ref, num_locations):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    locations = obj.get_all_locations()
    print(f"Checking if obtained num locations {len(locations)} == {num_locations}")
    assert len(locations) == int(num_locations)

@given('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in "{location}" location')
@when('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in "{location}" location')
@then('"{user_name}" calls get all locations for object "{obj_ref}" and check object is located in "{location}" location')
def step_impl(context, user_name, obj_ref, location):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    location_id = test_user.user_objects[location]
    locations = obj.get_all_locations()
    assert location_id in locations

@given('"{user_name}" sets "{obj_ref}" object hint to "{id_ref}"')
@when('"{user_name}" sets "{obj_ref}" object hint to "{id_ref}"')
@then('"{user_name}" sets "{obj_ref}" object hint to "{id_ref}"')
def step_impl(context, user_name, obj_ref, id_ref):
    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    location_id = test_user.user_objects[id_ref]
    obj.set_hint(location_id)