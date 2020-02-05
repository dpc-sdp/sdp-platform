<?php

namespace SdpPlatform\composer;

use Composer\Composer;
use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\Factory;
use Composer\IO\IOInterface;
use Composer\Plugin\PluginInterface;
use Composer\Script\Event;
use Composer\Script\ScriptEvents;

/**
 * Class Plugin - Installs SDP Platform requirements.
 *
 * @package SdpPlatform\composer
 */
class Plugin implements PluginInterface, EventSubscriberInterface {

  /**
   * The composer context for this plugin.
   *
   * @var \Composer\Composer
   */
  protected $composer;

  /**
   * Access to input/output.
   *
   * @var \Composer\IO\IOInterface
   */
  protected $io;

  /**
   * {@inheritdoc}
   */
  public function activate(Composer $composer, IOInterface $io) {
    $this->composer = $composer;
    $this->io = $io;
  }

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents() {
    return [
      ScriptEvents::POST_INSTALL_CMD => 'addPlatformFiles',
      ScriptEvents::POST_UPDATE_CMD => 'addPlatformFiles',
    ];
  }

  /**
   * Add/update platform files.
   *
   * @param \Composer\Script\Event $event
   *   The event from Composer that called this function.
   */
  public function addPlatformFiles(Event $event) {

    $baseDir = dirname(Factory::getComposerFile());
    $directoriesToCopy = [
      '.' => [
        '.ahoy.yml' => []
      ],
      '.circleci' => [
        'config.yml' => [],
        'export-config.sh' => [],
      ],
      'scripts' => [
        'export-config.sh' => [],
      ],
      'scripts/drupal' => [
        'backup.sh' => ['%%PROJECT_NAME%%' => 'PROJECT_NAME'],
      ],
    ];

    foreach ($directoriesToCopy as $directoryToCopy => $filesToCopy) {
      foreach ($filesToCopy as $fileToCopy => $replacements) {
        $source = __DIR__ . '/../../assets/' . $directoryToCopy . '/' . $fileToCopy;
        $target = $baseDir . '/' . $directoryToCopy . '/' . $fileToCopy;

        $fileContents = file_get_contents($source);
        if (!empty($replacements)) {
          foreach ($replacements as $search => $replaceName) {
            $replaceValue = getenv($replaceName);
            if (empty($replaceValue)) {
              print "Cannot find an environment variable for $replaceName\n";
            }
            else {
              print "Replacing $search with $replaceValue in $target\n";
              $fileContents = preg_replace("/$search/", $replaceValue, $fileContents);
            }
          }
        }
        print "Copying $source to $target\n";
        file_put_contents($target, $fileContents);
      }
    }

  }

}
