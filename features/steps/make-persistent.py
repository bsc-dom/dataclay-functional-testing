from steps.steps import *
import importlib

@given('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
@then('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
@when('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}", backend name = "{backend_name}" and recursive = "{recursive}"')
def make_persistent_step_impl(context, user_name, obj_ref, alias, backend_name, recursive):

    test_user = get_or_create_user(user_name)
    obj = test_user.user_objects[obj_ref]
    thealias = alias
    if alias == "null":
        thealias = None
    backend_id = None
    if backend_name != "null":
        from dataclay import api
        backend_id = api.get_backend_id_by_name(backend_name)
    rec = True
    if recursive == "False":
        rec = False
    obj.make_persistent(alias=thealias, backend_id=backend_id, recursive=rec)

@given('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}"')
@then('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}"')
@when('"{user_name}" runs make persistent for object "{obj_ref}" with alias = "{alias}"')
def step_impl(context, user_name, obj_ref, alias):
    make_persistent_step_impl(context, user_name, obj_ref, alias, "null", "True")

@given('"{user_name}" runs make persistent for object "{obj_ref}" with backend name = "{backend_name}"')
@then('"{user_name}" runs make persistent for object "{obj_ref}" with backend name = "{backend_name}"')
@when('"{user_name}" runs make persistent for object "{obj_ref}" with backend name = "{backend_name}"')
def step_impl(context, user_name, obj_ref, backend_name):
    make_persistent_step_impl(context, user_name, obj_ref, "null", backend_name, "True")

@given('"{user_name}" runs make persistent for object "{obj_ref}"')
@then('"{user_name}" runs make persistent for object "{obj_ref}"')
@when('"{user_name}" runs make persistent for object "{obj_ref}"')
def step_impl(context, user_name, obj_ref):
    make_persistent_step_impl(context, user_name, obj_ref, "null", "null", "True")