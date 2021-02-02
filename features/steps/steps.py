import os
from behave import *
import allure
import sys


class TestUser:
    """Test user"""

    def __init__(self, name):
        self.name = name
        self.user_objects = dict()
        self.client_properties_path = ""
        self.session_properties_path = ""
        self.account_name = ""
        self.account_pwd = ""
        self.docker_network = ""


ALL_TEST_USERS = dict()

def get_or_create_user(user_name):
    test_user = None
    if user_name not in ALL_TEST_USERS.keys():
        test_user = TestUser(user_name)
        ALL_TEST_USERS[user_name] = test_user
        test_user.docker_network = f"dataclay-testing-network"
        create_docker_network(test_user.docker_network)
    else:
        test_user = ALL_TEST_USERS.get(user_name)
    connect_to_docker_network(test_user.docker_network)
    return test_user


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def get_docker_images_to_use(context):
    pyver = context.config.userdata['pyver'].replace(".","")
    img = context.config.userdata['image']
    arch = context.config.userdata['arch']
    if img != "normal":
        if arch == "linux/arm/v7" and img == "alpine":
            # Alpine images for arm not supported
            print("WARNING: alpine images in linux/arm/v7 not available, using slim images instead")
            dockerimg = f"develop.py{pyver}-{img}"
            javadockerimg = "develop-slim"
        else:
            dockerimg = f"develop.py{pyver}-{img}"
            javadockerimg = f"develop-{img}"
    else:
        dockerimg = f"develop.py{pyver}"
        javadockerimg = f"develop"
    return dockerimg, javadockerimg


def dockercompose(context, docker_compose_path, testing_network, command, command_output=None):
    """Calls docker-compose
        :param docker_compose_path: the docker-compose.yml file path
        :type docker_compose_path: string
        :param testing_network: name of network for docker compose
        :type testing_network: str
        :param command: the docker-compose command to run
        :type command: string
        :param command_output: where to save docker command output
        :type command_output: string
    """

    dockerimg, javadockerimg = get_docker_images_to_use(context)
    arch = context.config.userdata['arch']
    pwd = to_absolute_path_for_docker_volumes(context, "")
    cmd = f"docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v {pwd}:{pwd} \
            -e PYCLAY_IMAGE={dockerimg} -e JAVACLAY_IMAGE={javadockerimg} \
            -e IMAGE_PLATFORM={arch} -e TESTING_NETWORK={testing_network} \
            -w={pwd} linuxserver/docker-compose -f {docker_compose_path} {command}"
    eprint(cmd)
    os.system(cmd)


def dataclaysrv(context, docker_compose_file, testing_network, command, command_output=None):
    """Manages dataClay docker services
        :param context: the current feature context
        :type context: context
        :param docker_compose_file: docker compose file to use
        :type docker_compose_file: str
        :param testing_network: name of network for docker compose
        :type testing_network: str
        :param command: command for dataclay services, it can be start, stop, kill,...
        :type command: string
        :param command_output: where to save docker command output
        :type command_output: string
    """
    if command == "start":
        dockercompose(context, docker_compose_file, testing_network, "up -d", command_output=command_output)
    elif command == "stop":
        dockercompose(context, docker_compose_file, testing_network, "down -v", command_output=command_output)
    elif command == "config":
        dockercompose(context, docker_compose_file, testing_network, "config", command_output=command_output)
    elif command == "logs":
        dockercompose(context, docker_compose_file, testing_network, "logs --no-color", command_output=command_output)
    elif command == "kill":
        dockercompose(context, docker_compose_file, testing_network, "kill", command_output=command_output)
        dockercompose(context, docker_compose_file, testing_network, "rm -s -f -v", command_output=command_output)

def dataclaycmd(context, client_properties_path, testing_network, command, command_mount_points=None):
    """Runs a dataclaycmd (NewAccount, NewModel,...)
        :param context: the current feature context
        :type context: context
        :param client_properties_path: path client properties to be used
        :param client_properties_path: str
        :param testing_network: name of network for docker compose
        :type testing_network: str
        :param command: command to run
        :type command: string
        :param command_mount_points: folders to mount inside the container
        :type command_mount_points: string
    """
    mount_points = f"-v {client_properties_path}:/home/dataclayusr/dataclay/cfgfiles/client.properties:ro"
    if command_mount_points is not None:
        for mnt_point in command_mount_points:
            mount_points = f"{mount_points} -v {mnt_point}"
    arch = context.config.userdata['arch']
    dockerimg, javadockerimg = get_docker_images_to_use(context)

    user_id = context.config.userdata['userID']
    group_id = context.config.userdata['groupID']
    debug_flag = ""
    if os.getenv("DEBUG") == "True":
        debug_flag = "--debug"
    cmd = f"docker run --platform {arch} --network={testing_network} {mount_points} \
        -e HOST_USER_ID={user_id} -e HOST_GROUP_ID={group_id} \
        bscdataclay/client:{javadockerimg} {command} {debug_flag}"
    print(cmd)
    os.system(cmd)

def get_logicmodule_ip_of_user_network(user_name_network):
    cmd = f"docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {user_name_network}_logicmodule"
    print(cmd)
    return os.popen(cmd).read().replace("'","")


def to_absolute_path_for_docker_volumes(context, path):
    """
    Return absolute path to use in docker volume command
    :param context: test context
    :param path: relative path
    :return: absoulte path to use in docker -v
    """
    host_pwd = context.config.userdata['host_pwd']
    return "%s/%s" % (host_pwd, path)

def prepare_images(context):
    """
    Prepare docker images according to tested arch, python version...
    :param context: Context
    :return: None
    """
    arch = context.config.userdata['arch']
    dockerimg, javadockerimg = get_docker_images_to_use(context)
    # Do not force pull linux/amd64 images to allow local testing
    if arch != "linux/amd64":
        platform_arg = f"--platform {arch}"
        os.system(f"docker pull {platform_arg} linuxserver/docker-compose")
        os.system(f"docker pull {platform_arg} bscdataclay/logicmodule:{javadockerimg}")
        os.system(f"docker pull {platform_arg} bscdataclay/dsjava:{javadockerimg}")
        os.system(f"docker pull {platform_arg} bscdataclay/client:{javadockerimg}")
        os.system(f"docker pull {platform_arg} bscdataclay/dspython:{dockerimg}")


def clean_dataclay(context, docker_compose_path, testing_network):
    """Kills all dataClay docker services
        :param context: the current feature context
        :type context: context
        :param docker_compose_path: path to docker compose
        :type docker_compose_path: str
        :param testing_network: name of network for docker compose
        :type testing_network: str
    """
    dataclaysrv(context, docker_compose_path, testing_network, "kill")

def save_logs(context, docker_compose_path, testing_network):
    """Save logs from dataClay docker services
        :param context: the current feature context
        :type context: context
        :param docker_compose_path: path to docker compose
        :type docker_compose_path: str
        :param testing_network: name of network for docker compose
        :type testing_network: str
    """
    pass
    #allure.attach.file(log_path, "dockerlogs.txt", attachment_type=allure.attachment_type.TEXT)


def clean_scenario(context):
    """Clean feature scenario (stubs, temporary files...)
        :param context: the current feature context
        :type context: context
        :param scenario: the current feature scenario
        :type scenario: scenario
    """
    cmd = "/bin/bash resources/utils/clean_scenario.sh"
    print(cmd)
    os.system(cmd)


def create_docker_network(network_name):
    """
    Create docker network
    :param network_name: name of docker network to create
    """
    if not network_name.startswith("dataclay-testing"):
        raise Exception("Docker network name must start with dataclay-testing")

    cmd = f"docker network create {network_name}"
    print(cmd)
    os.system(cmd)

def connect_to_docker_network(network_name):
    """
    Attach to docker network
    :param network_name: name of docker network
    """
    if not network_name.startswith("dataclay-testing"):
        raise Exception("Docker network name must start with dataclay-testing")

    cmd = f"/bin/bash resources/utils/connect_network.sh {network_name}"
    print(cmd)
    os.system(cmd)

def disconnect_from_docker_network(network_name):
    """
    Attach to docker network
    :param network_name: name of docker network
    """
    if not network_name.startswith("dataclay-testing"):
        raise Exception("Docker network name must start with dataclay-testing")

    cmd = f"/bin/bash resources/utils/disconnect_network.sh {network_name}"
    print(cmd)
    os.system(cmd)

def remove_docker_network(network_name):
    """
    Remove docker network
    :param network_name: name of docker network
    """
    if not network_name.startswith("dataclay-testing"):
        raise Exception("Docker network name must start with dataclay-testing")
    cmd = f"docker network rm {network_name}"
    print(cmd)
    os.system(cmd)

@given('"{user_name}" has a configuration file "{cfgfile_path}" to be used to connect to dataClay')
def step_impl(context, user_name, cfgfile_path):
    """ Specify path to configuration file to be used
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param cfgfile_path: path to configuration file to be used
        :type cfgfile_path: string
    """
    test_user = get_or_create_user(user_name)
    test_user.client_properties_path = to_absolute_path_for_docker_volumes(context, cfgfile_path)
    allure.attach.file(cfgfile_path, "mgm_cfgfile.properties", attachment_type=allure.attachment_type.TEXT)


@given(u'"{user_name}" deploys dataClay with docker-compose.yml file "{docker_compose_path}"')
def step_impl(context, user_name, docker_compose_path):
    """ Deploy dataClay for current feature
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param context: the current feature context
        :type docker_compose_path: docker compose to be used
    """
    test_user = get_or_create_user(user_name)
    dataclaysrv(context, docker_compose_path, test_user.docker_network, "start")
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network, "WaitForDataClayToBeAlive 10 5")
    allure.attach.file(docker_compose_path, "docker-compose.yml", attachment_type=allure.attachment_type.TEXT)


@given('"{user_name}" has a session file "{sessionfile_path}" to be used in test application')
def step_impl(context,  user_name, sessionfile_path):
    """ Specify path to session file to be used in test application
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param sessionfile_path: path to session file to be used in test application
        :type sessionfile_path: string
    """
    actual_sessionfile_path = sessionfile_path
    test_type = os.getenv("TEST_TYPE")
    test_user = get_or_create_user(user_name)
    if test_type is not None and test_type == "local":
        last_bar_index = sessionfile_path.rfind("/") + 1
        first_part = sessionfile_path[0:last_bar_index]
        second_part = sessionfile_path[last_bar_index:]
        new_second_part = f"local{second_part}"
        actual_sessionfile_path = f"{first_part}{new_second_part}"
        print(f"Actual session is {actual_sessionfile_path}")
        test_user.session_properties_path = to_absolute_path_for_docker_volumes(context, actual_sessionfile_path)
    else:
        test_user.session_properties_path = actual_sessionfile_path

    allure.attach.file(test_user.session_properties_path, "session.properties", attachment_type=allure.attachment_type.TEXT)


@given('"{user_name}" creates an account named "{account_name}" with password "{account_pwd}"')
def step_impl(context, user_name, account_name, account_pwd):
    """ Create a new account in dataClay
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param account_name: name of the account to create
        :type account_name: string
        :param account_pwd: password of the account
        :type account_pwd: string
    """
    test_user = get_or_create_user(user_name)
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network, f"NewAccount {account_name} {account_pwd}")
    test_user.account_name = account_name
    test_user.account_pwd = account_pwd


@given('"{user_name}" creates a dataset named "{dataset_name}"')
def step_impl(context, user_name, dataset_name):
    """ Create a new dataset in dataClay
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param dataset_name: name of the dataset to create
        :type dataset_name: string
    """
    pass


@given('"{user_name}" creates a namespace named "{namespace_name}"')
def step_impl(context, user_name, namespace_name):
    """ Create a new namespace in dataClay
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param namespace_name: name of the namespace to create
        :type namespace_name: string
    """
    pass


@given('"{user_name}" creates a datacontract allowing access to dataset "{dataset}" to user "{user}"')
def step_impl(context, user_name, dataset, user):
    """ Create a new datacontract in dataClay
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param dataset: name of the dataset user can access
        :type dataset: string
        :param user: name of the user with access to dataset
        :type user: string
    """
    test_user = get_or_create_user(user_name)
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network,
                f"NewDataContract {test_user.account_name} {test_user.account_pwd} {dataset} {user}")


@given('"{user_name}" registers a model located at "{model_path}" into namespace "{namespace}"')
def step_impl(context, user_name, model_path, namespace):
    """ Register a model
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param model_path: location of model being registered
        :type model_path: string
        :param namespace: namespace of model being registered
        :type namespace: string
    """
    test_user = get_or_create_user(user_name)
    model_abs_path = to_absolute_path_for_docker_volumes(context, model_path)
    command_mount_points = [f"{model_abs_path}:/home/dataclayusr/model:ro"]
    dataclaycmd(context,  test_user.client_properties_path, test_user.docker_network,
                f"NewModel {test_user.account_name} {test_user.account_pwd} {namespace} /home/dataclayusr/model python", command_mount_points=command_mount_points)

    for classfile in os.listdir(model_path):
        classfile_path = os.path.join(model_path, classfile)
        allure.attach.file(classfile_path, classfile, attachment_type=allure.attachment_type.TEXT)


@given('"{user_name}" get stubs from namespace "{namespace}" into "{stubs_path}" directory')
def step_impl(context, user_name, namespace, stubs_path):
    """ Get stubs
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
        :param namespace: namespace of stubs
        :type namespace: string
        :param stubs_path: location where to store stubs
        :type stubs_path: string
    """
    test_user = get_or_create_user(user_name)
    stubs_abs_path = to_absolute_path_for_docker_volumes(context, stubs_path)
    command_mount_points = [f"{stubs_abs_path}:/home/dataclayusr/stubs:rw"]
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network,
                f"GetStubs {test_user.account_name} {test_user.account_pwd} {namespace} /home/dataclayusr/stubs", command_mount_points = command_mount_points)

@given('"{user_name}" waits until dataClay has {num_nodes} backends of "{language}" language')
def step_impl(context, user_name, num_nodes, language):
    test_user = get_or_create_user(user_name)
    dataclaycmd(context, test_user.client_properties_path, test_user.docker_network,
                f"WaitForBackends {language} {num_nodes}")


@given('"{user_name}" starts a new session')
def step_impl(context, user_name):
    """ Start a new session
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
    """
    test_user = get_or_create_user(user_name)
    os.environ["DATACLAYSESSIONCONFIG"] = test_user.session_properties_path
    from dataclay.api import init
    init()

@given('"{user_name}" finishes the session')
@then('"{user_name}" finishes the session')
def step_impl(context, user_name):
    """ Finish a session
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
    """
    from dataclay.api import finish
    finish()