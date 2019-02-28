package io.microconfig.configs.io.ioservice.properties;

import io.microconfig.configs.io.ioservice.ConfigIoService;
import io.microconfig.configs.io.ioservice.ConfigReader;
import io.microconfig.configs.io.ioservice.ConfigWriter;
import io.microconfig.utils.reader.FileReader;
import lombok.RequiredArgsConstructor;

import java.io.File;

@RequiredArgsConstructor
public class PropertiesConfigIoService implements ConfigIoService {
    private final FileReader fileReader;

    @Override
    public ConfigReader read(File file) {
        return new PropertiesReader(file, fileReader);
    }

    @Override
    public ConfigWriter writeTo(File file) {
        return new PropertiesWriter(file);
    }
}