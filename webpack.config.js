const path = require('path');

module.exports = {
    entry: {
        index: './frontend/index.ts',
        music_control: './frontend/music_control.ts'
    },
    module: {
        rules: [
            {
                use: 'ts-loader'
            }
        ]
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, 'static/js')
    }
};
