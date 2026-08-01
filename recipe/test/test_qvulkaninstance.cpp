#include <QtGui/qtguiglobal.h>

#if !QT_CONFIG(vulkan)
#error "QtGui was built without Vulkan support"
#endif

#include <QVulkanInstance>

int main()
{
    QVulkanInstance instance;
    return instance.vkInstance() == VK_NULL_HANDLE ? 0 : 1;
}
