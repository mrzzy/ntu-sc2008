/*
 * SC2008
 * Lab 2
 * Server
*/
package sc2008_lab;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class App {
    private static final byte[] QUOTE = "This is a quote".getBytes();

    public static void main(String[] args) {
        // open udp socket on port 17 to listen for quote of the day requests
        try (DatagramSocket socket = new DatagramSocket(17)) {
            while (true) {
                try {
                    // listen for qotd requests
                    DatagramPacket inPacket = new DatagramPacket(new byte[1], 1);
                    socket.receive(inPacket);
                    // ignore contents of input packet

                    // write quote of the day in output packet
                    DatagramPacket outPacket = new DatagramPacket(QUOTE, QUOTE.length, inPacket.getAddress(),
                            inPacket.getPort());
                    socket.send(outPacket);
                } catch (IOException e) {
                    System.out.println("IO exception reading or writing socket");
                    e.printStackTrace();
                }
            }
        } catch (SocketException e) {
            throw new RuntimeException(e);
        }
    }
}
