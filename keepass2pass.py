from subprocess import Popen,PIPE
from xml.etree import ElementTree as ET

if __name__ == "__main__":
    root = ET.parse(sys.argv[0])
    for group in root.findall("Root/Group/Group"):
        group_title = group.find("Name").text
        for entry in group.findall("Entry"):
            password = None
            title = None
            notes = None
            username = None

            for item in entry.findall("String"):
                text = item.find("Key").text
                value = item.find("Value").text

                if text == "Password":
                    password = value
                elif text == "Title":
                    title = value
                elif text == "Notes":
                    notes = value
                elif text == "Username":
                    username = value

            data = password+"\n"
            if username:
                data += "Username: %s\n" % username
            if notes:
                data += "Notes: %s\n" % notes

            proc = Popen(['pass', 'insert', '--multiline', '--force', "%s/%s" % (group_title,title)],
                        stdin=PIPE, stdout=PIPE)
            proc.communicate(data.encode('utf8'))
            proc.wait()
