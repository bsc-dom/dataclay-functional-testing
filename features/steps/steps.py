import os
from behave import *
import allure
import sys

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

def dockercompose(context, docker_compose_path, command, command_output=None):
    """Calls docker-compose
        :param docker_compose_path: the docker-compose.yml file path
        :type docker_compose_path: string
        :param command: the docker-compose command to run
        :type command: string
        :param command_output: where to save docker command output
        :type command_output: string
    """

    dockerimg, javadockerimg = get_docker_images_to_use(context)
    if docker_compose_path not in context.docker_composes :
        context.docker_composes.append(docker_compose_path)
    pwd = to_absolute_path_for_docker_volumes(context, "")
    cmd = f"docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v {pwd}:{pwd} \
            -e PYCLAY_IMAGE={dockerimg} -e JAVACLAY_IMAGE={javadockerimg} \
            -w={pwd} linuxserver/docker-compose -f {docker_compose_path} {command}"
    eprint(cmd)
    os.system(cmd)


def dataclaysrv(context, command, command_output=None):
    """Manages dataClay docker services
        :param context: the current feature context
        :type context: context
        :param command: command for dataclay services, it can be start, stop, kill,...
        :type command: string
        :param command_output: where to save docker command output
        :type command_output: string
    """
    if hasattr(context, "docker_composes"):
        for docker_compose_file in context.docker_composes:
            if command == "start":
                dockercompose(context, docker_compose_file, "up -d", command_output=command_output)
            elif command == "stop":
                dockercompose(context, docker_compose_file, "down -v", command_output=command_output)
            elif command == "config":
                dockercompose(context, docker_compose_file, "config", command_output=command_output)
            elif command == "logs":
                dockercompose(context, docker_compose_file, "logs --no-color", command_output=command_output)
            elif command == "kill":
                dockercompose(context, docker_compose_file, "kill", command_output=command_output)
                dockercompose(context, docker_compose_file, "rm -s -f -v", command_output=command_output)

def dataclaycmd(context, command, command_mount_points=None):
    """Runs a dataclaycmd (NewAccount, NewModel,...)
        :param context: the current feature context
        :type context: context
        :param command: command to run
        :type command: string
        :param command_mount_points: folders to mount inside the container
        :type command_mount_points: string
    """
    network = context.config.userdata['test_network']
    mount_points = f"-v {context.mgm_cfgfile_path}:/home/dataclayusr/dataclay/cfgfiles/client.properties:ro"
    if command_mount_points is not None:
        for mnt_point in command_mount_points:
            mount_points = f"{mount_points} -v {mnt_point}"
    arch = context.config.userdata['arch']
    dockerimg, javadockerimg = get_docker_images_to_use(context)

    # Do not force pull linux/amd64 images to allow local testing
    platform_arg = ""
    if arch != "linux/amd64":
        platform_arg = f"--platform {arch}"
    user_id = context.config.userdata['userID']
    group_id = context.config.userdata['groupID']

    cmd = f"docker run --rm {platform_arg} --network={network} {mount_points} \
        -e HOST_USER_ID={user_id} -e HOST_GROUP_ID={group_id} \
        bscdataclay/client:{javadockerimg} {command}"
    print(cmd)
    os.system(cmd)


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


def clean_dataclay(context):
    """Kills all dataClay docker services
        :param context: the current feature context
        :type context: context
    """
    dataclaysrv(context, "kill")

def save_logs(context):
    """Save logs from dataClay docker services
        :param context: the current feature context
        :type context: context
    """
    log_path = "%dockerlogs.txt"
    with open(log_path, "w") as log_file:
        dataclaysrv(context, "logs", command_output=log_file)

    #allure.attach.file(log_path, "dockerlogs.txt", attachment_type=allure.attachment_type.TEXT)


def clean_scenario(context, scenario):
    """Clean feature scenario (stubs, temporary files...)
        :param context: the current feature context
        :type context: context
        :param scenario: the current feature scenario
        :type scenario: scenario
    """
    pass



@given(u'A docker-compose.yml file for deployment at "{docker_compose_path}"')
def step_impl(context, docker_compose_path):
    """ Deploy dataClay for current feature
        :param context: the current feature context
        :type docker_compose_path: docker compose to be used
    """
    if not hasattr(context, "docker_composes"):
        context.docker_composes = list()
    context.docker_composes.append(docker_compose_path)
    allure.attach.file(docker_compose_path, "docker-compose.yml", attachment_type=allure.attachment_type.TEXT)


@given('I deploy dataClay with docker-compose')
def step_impl(context):
    """ Deploy dataClay for current feature
        :param context: the current feature context
        :type context: context
    """
    clean_dataclay(context)
    dataclaysrv(context, "start")
    dataclaycmd(context, "WaitForDataClayToBeAlive 10 5")


@given('A configuration file "{mgm_cfgfile_path}" to be used in management operations')
def step_impl(context, mgm_cfgfile_path):
    """ Specify path to configuration file to be used in management operations
        :param context: the current feature context
        :type context: context
        :param mgm_cfgfile_path: path to configuration file to be used in management
        :type mgm_cfgfile_path: string
    """
    context.mgm_cfgfile_path = to_absolute_path_for_docker_volumes(context, mgm_cfgfile_path)
    allure.attach.file(mgm_cfgfile_path, "mgm_cfgfile.properties", attachment_type=allure.attachment_type.TEXT)


@given('A configuration file "{cfgfile_path}" to be used in test application')
def step_impl(context, cfgfile_path):
    """ Specify path to configuration file to be used in test application
        :param context: the current feature context
        :type context: context
        :param cfgfile_path: path to configuration file to be used in test application
        :type cfgfile_path: string
    """
    context.cfgfile_path = to_absolute_path_for_docker_volumes(context, cfgfile_path)
    os.environ["DATACLAYCLIENTCONFIG"] = context.cfgfile_path
    allure.attach.file(cfgfile_path, "client.properties", attachment_type=allure.attachment_type.TEXT)


@given('A session file "{sessionfile_path}" to be used in test application')
def step_impl(context, sessionfile_path):
    """ Specify path to session file to be used in test application
        :param context: the current feature context
        :type context: context
        :param sessionfile_path: path to session file to be used in test application
        :type sessionfile_path: string
    """
    actual_sessionfile_path = sessionfile_path
    test_type = os.getenv("TEST_TYPE")
    if test_type is not None and test_type == "local":
        last_bar_index = sessionfile_path.rfind("/") + 1
        first_part = sessionfile_path[0:last_bar_index]
        second_part = sessionfile_path[last_bar_index:]
        new_second_part = f"local{second_part}"
        actual_sessionfile_path = f"{first_part}{new_second_part}"
        print(f"Actual session is {actual_sessionfile_path}")
        context.sessionfile_path = to_absolute_path_for_docker_volumes(context, actual_sessionfile_path)
    else:
        context.sessionfile_path = actual_sessionfile_path

    os.environ["DATACLAYSESSIONCONFIG"] = context.sessionfile_path
    allure.attach.file(context.sessionfile_path, "session.properties", attachment_type=allure.attachment_type.TEXT)


@given('I create an account named "{account_name}" and password "{account_pwd}"')
def step_impl(context, account_name, account_pwd):
    """ Create a new account in dataClay
        :param context: the current feature context
        :type context: context
        :param account_name: name of the account to create
        :type account_name: string
        :param account_pwd: password of the account
        :type account_pwd: string
    """
    dataclaycmd(context, f"NewAccount {account_name} {account_pwd}")
    context.account_name = account_name
    context.account_pwd = account_pwd


@given('I create a dataset named "{dataset_name}"')
def step_impl(context, dataset_name):
    """ Create a new dataset in dataClay
        :param context: the current feature context
        :type context: context
        :param dataset_name: name of the dataset to create
        :type dataset_name: string
    """
    pass


@given('I create a namespace named "{namespace_name}"')
def step_impl(context, namespace_name):
    """ Create a new namespace in dataClay
        :param context: the current feature context
        :type context: context
        :param namespace_name: name of the namespace to create
        :type namespace_name: string
    """
    pass


@given('I create a datacontract allowing access to dataset "{dataset}" to user "{user}"')
def step_impl(context, dataset, user):
    """ Create a new datacontract in dataClay
        :param context: the current feature context
        :type context: context
        :param dataset: name of the dataset user can access
        :type dataset: string
        :param user: name of the user with access to dataset
        :type user: string
    """
    dataclaycmd(context, f"NewDataContract {context.account_name} {context.account_pwd} {dataset} {user}")


@given('I register a model located at "{model_path}" into namespace "{namespace}"')
def step_impl(context, model_path, namespace):
    """ Register a model
        :param context: the current feature context
        :type context: context
        :param model_path: location of model being registered
        :type model_path: string
        :param namespace: namespace of model being registered
        :type namespace: string
    """
    model_abs_path = to_absolute_path_for_docker_volumes(context, model_path)
    command_mount_points = [f"{model_abs_path}:/home/dataclayusr/model:ro"]
    dataclaycmd(context, f"NewModel {context.account_name} {context.account_pwd} {namespace} /home/dataclayusr/model python", command_mount_points=command_mount_points)

    for classfile in os.listdir(model_path):
        classfile_path = os.path.join(model_path, classfile)
        allure.attach.file(classfile_path, classfile, attachment_type=allure.attachment_type.TEXT)


@given('I get stubs from namespace "{namespace}" into "{stubs_path}" directory')
def step_impl(context, namespace, stubs_path):
    """ Get stubs
        :param context: the current feature context
        :type context: context
        :param namespace: namespace of stubs
        :type namespace: string
        :param stubs_path: location where to store stubs
        :type stubs_path: string
    """
    stubs_abs_path = to_absolute_path_for_docker_volumes(context, stubs_path)
    command_mount_points = [f"{stubs_abs_path}:/home/dataclayusr/stubs:rw"]
    dataclaycmd(context, f"GetStubs {context.account_name} {context.account_pwd} {namespace} /home/dataclayusr/stubs", command_mount_points = command_mount_points)


@given('I start extra nodes using "{docker_compose_extra_path}"')
def step_impl(context, docker_compose_extra_path):
    """
    Start extra nodes
    :param context: feature context
    :param docker_compose_extra_path: docker-compose to use for start
    :return: None
    """
    dockercompose(context, docker_compose_extra_path, "up -d")
    allure.attach.file(docker_compose_extra_path, "docker-compose-extra.yml", attachment_type=allure.attachment_type.TEXT)

@given('I wait until dataClay has "{num_nodes}" backends')
def step_impl(context, num_nodes):
    dataclaycmd(context, f"WaitForBackends python {num_nodes}")


@given('I start a new session')
def step_impl(context):
    """ Start a new session
        :param context: the current feature context
        :type context: context
    """
    from dataclay.api import init
    init()


@then('I finish the session')
def step_impl(context):
    """ Finish a session
        :param context: the current feature context
        :type context: context
    """
    from dataclay.api import finish
    finish()

@given('I run make persistent for an object')
@then('I run make persistent for an object')
def step_impl(context):
    """ Run make persistent 
        :param context: the current feature context
        :type context
    """
    from test_namespace.classes import Person, People
    person = Person("Bob", 33)
    person.make_persistent()
    context.person = person


@then('I run a LOCAL make persistent for an object')
def step_impl(context):
    """ Run make persistent 
        :param context: the current feature context
        :type context
    """
    from dataclay import api
    from test_namespace.classes import Person, People
    person = Person("Bob", 33)
    person.make_persistent(backend_id=api.LOCAL)
    context.person = person


@given('I run make persistent for an object with alias "{alias}"')
def step_impl(context, alias):
    """ Run make persistent with alias
        :param context: the current feature context
        :param alias: alias
    """
    from test_namespace.classes import Person, People
    person = Person("Bob", 33)
    person.make_persistent(alias=alias)
    context.person = person


@then('I get the object with alias "{alias}"')
def step_impl(context, alias):
    """
    Get object by alias
    :param context: test context
    :param alias: alias of the object to get
    """
    from test_namespace.classes import Person, People
    person = Person.get_by_alias(alias)
    print(person)

@given('I set object to be read only')
@then('I set object to be read only')
def step_impl(context):
    """ Set object person to be read only
        :param context: the current feature context
        :type context: context
    """
    #context.person.set_read_only()
    pass


@when('I call new replica')
def step_impl(context):
    """
    Call new replica
    :param context: the current feature context
    :type context: context
    """
    context.person.new_replica()


@then('I get object locations and I see object is located in two locations')
def step_impl(context):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    """
    from dataclay import api
    locations = context.person.get_all_locations()
    print(locations)
    assert len(locations) == 2