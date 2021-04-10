from steps.steps import *

@given('"{user_name}" starts extra nodes using "{docker_compose_extra_path}"')
def step_impl(context, user_name, docker_compose_extra_path):
    """
    Start extra nodes
    :param context: feature context
    :param docker_compose_extra_path: docker-compose to use for start
    :param user_name: user name
    :type user_name: string
    :return: None
    """
    test_user = get_or_create_user(user_name)
    dockercompose(context, docker_compose_extra_path, test_user.docker_network, test_user.env_vars, "up -d")
    allure.attach.file(docker_compose_extra_path, "docker-compose-extra.yml", attachment_type=allure.attachment_type.TEXT)
